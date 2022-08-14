#!/bin/bash
echo "Plugin name without any separator:"
read name && mkdir $name && cd $name

pwd=`pwd`

cat > webpack.config.js << EOF
const defaultConfig = require( '@wordpress/scripts/config/webpack.config' )
const BrowserSyncPlugin = require('browser-sync-webpack-plugin')
module.exports = {
	...defaultConfig,
	plugins: [
		...defaultConfig.plugins,
		new BrowserSyncPlugin({
			host: 'localhost',
			port: 3000,
			proxy: 'http://$name.local/'
		})
	]
}
EOF

cat > $name.php << EOF
<?php
/**
 * Plugin Name:       $name
 * Plugin URI:        https://www.webaxones.com
 * Description:       $name
 * Version: 1.0.0
 * Requires at least: 6.0
 * Requires PHP: 8.0
 * Author:            Loïc Antignac
 * Author URI:        https://www.webaxones.com
 * License:           GPL v2 or later
 * License URI:       https://www.gnu.org/licenses/gpl-2.0.html
 * Text Domain:       $name
 */

namespace ${name}\Builder;

defined( 'ABSPATH' ) || exit;

/**
 * Main class for builder
 *
 * @throws
 */
class ${name}Builder
{
	/**
	 * Hooks
	 */
	public function __construct()
	{
		add_action( 'init', [ $this, 'builderInit' ] );
		add_action( 'init', [ $this, 'adminAssets' ] );
	}

	/**
	 * Register block types
	 *
	 * @return void
	 */
	public function builderInit(): void
	{
		register_block_type( __DIR__ . '/build/blocks/bloc1/' );
	}

	/**
	 * Register and enqueue builder overrides script
	 *
	 * @return void
	 */
	public function adminAssets(): void
	{
		$editor_script = include plugin_dir_path( __FILE__ ) . 'build/overrides/index.asset.php';
		wp_enqueue_script(
			'${name}builder',
			plugin_dir_url( __FILE__ ) . 'build/overrides/index.js',
			$editor_script['dependencies'],
			$editor_script['version'],
			1.0,
			true
		);
	}

	public function blockStylesAssets(): void
	{
		wp_enqueue_script(
			'${name}builder',
			plugin_dir_url( __FILE__ ) . 'build/blockstyles/blockstyles.js',
			array( 'wp-blocks', 'wp-dom' ),
			wp_get_theme()->get( 'Version' ),
			true
		);
	}
}

$builder = new ${name}Builder();
EOF

npm init -y
npm i @wordpress/scripts --save-dev
npm i @wordpress/blocks --save-dev
npm i @wordpress/dom-ready --save-dev
npm i browser-sync-webpack-plugin --save-dev
npm i del-cli --save-dev
npm i npm-run-all --save-dev
npmAddScript -k build-blocks -v "wp-scripts build"
npmAddScript -k build-overrides -v "wp-scripts build src/index.js --output-path=build/overrides"
npmAddScript -k build -v "npm run build-blocks && npm run build-overrides && del-cli build/overrides/blocks"
npmAddScript -k start-blocks -v "wp-scripts start"
npmAddScript -k start-overrides -v "wp-scripts start src/index.js --output-path=build/overrides"
npmAddScript -k start -v "npm-run-all --parallel start-blocks start-overrides"


mkdir src && cd src
mkdir blocks && mkdir components && mkdir overrides && mkdir styles && mkdir variations

cat > index.js << EOF
import './styles'
import './overrides'
EOF

cd blocks && mkdir block1
> edit.js
> save.js
> style.scss
> editor.scss
cat > index.js << EOF
import { registerBlockType } from '@wordpress/blocks'
import './style.scss'
import Edit from './edit'
import save from './save'
import metadata from './block.json'
registerBlockType( metadata.name, {
	edit: Edit,
	save,
} )
EOF

cat > block.json << EOF
{
	"$schema": "https://schemas.wp.org/trunk/block.json",
	"apiVersion": 2,
	"name": "$name/block1",
	"title": "Bloc 1",
	"version": "0.1.0",
	"category": "text",
	"icon": "text",
	"description": "A new block",
	"attributes": {},
	"supports": {
		"html": false
	},
	"example":{},
	"textdomain": "$name",
	"editorScript": "file:./index.js",
	"editorStyle": "file:./index.css",
	"style": "file:./style-index.css"
}
EOF

cd $pwd/src/styles

> editor.scss
> style.scss
cat > index.js << EOF
import './editor.scss'
import './style.scss'
EOF

cd $pwd/src/overrides
mkdir blockstyles
cd blockstyles
> registerBlockStyle.js
> unregisterBlockStyle.js
cat > index.js << EOF
import './registerBlockStyle.js'
import './unregisterBlockStyle.js'
EOF

cd $pwd

npm run build