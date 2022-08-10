#!/bin/bash
echo "Nom du plugin :"
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

cat > index.php << EOF
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
  
  defined( 'ABSPATH' ) || exit;
  
  function ${name}_block_init() {
      register_block_type( __DIR__ . '/build' );
  }
  add_action( 'init', "${name}_block_init" );
EOF

npm init -y
npm i @wordpress/scripts --save-dev
npm i browser-sync-webpack-plugin --save-dev
npmAddScript -k build -v "wp-scripts build src/index.js"
npmAddScript -k start -v "wp-scripts start src/index.js"


mkdir src && cd src
mkdir blocks && mkdir components && mkdir overrides && mkdir styles && mkdir variations

cat > index.js << EOF
  import './styles'
  import { registerBlockType, registerBlockVariation } from '@wordpress/blocks'
  import { __ } from '@wordpress/i18n'
  import { addFilter } from '@wordpress/hooks'
  import { filterBlockListBlock } from './overrides/filterBlockListBlock.js'
  import './overrides/unregisterFormatType.js'
  import './overrides/unregisterBlockStyle.js'
    
  import * as block1 from './blocks/block1'

  /**
   * Blocks
   */
  const blocks = [
	block1,
  ]
  
  const registerBlock = ( block ) => {
	  const { metadata, edit, save } = block.settings
	  registerBlockType( metadata, { edit, save } )
  }

  blocks.forEach( registerBlock )

  /**
   * Variations
   */
  const variations = [
  ]

  const registerVariation = ( variation ) => {
	  const { metadata, edit, save } = variation.settings
	  registerBlockVariation( metadata, { edit, save } )
  }

  variations.forEach( registerVariation )

  /**
   * Filters
   */
  addFilter( 'editor.BlockListBlock', '$name', filterBlockListBlock )
  addFilter( 'blocks.registerBlockType', '$name', filterRegisterBlockType )
EOF

cd blocks && mkdir bloc1 && cd bloc1 && mkdir styles
> edit.js
> save.js
cat > index.js << EOF
  import './styles/editor.scss'
  import './styles/style.scss'
  import edit from './edit.js'
  import save from './save.js'
  import metadata from './block.json'

  export const settings = {
	  metadata,
	  edit,
	  save
  }
EOF

cat > block.json << EOF
  {
	  "$schema": "https://schemas.wp.org/trunk/block.json",
	  "apiVersion": 2,
	  "name": "$name/bloc1",
	  "title": "Bloc 1",
	  "version": "0.1.0",
	  "category": "text",
	  "icon": "text",
	  "description": "A new block",
	  "attributes": {},
	  "supports": {
		  "html": false,
		  "reusable":false
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
cat > filterBlockListBlock.js << EOF
  import { createHigherOrderComponent } from '@wordpress/compose'
  
  export const filterBlockListBlock = createHigherOrderComponent( ( BlockListBlock ) => {
  	  return ( props ) => {
  
  		  const { attributes } = props
  
  		  if( attributes.hasOwnProperty('className') && '' !== attributes.className ) {
  			  return <BlockListBlock { ...props } className={ attributes.className } />
  		  }
  
  		  return <BlockListBlock {...props} />
  	  }
  }, 'filterBlockListBlock' )
EOF

cat > unregisterBlockStyle.js << EOF
  wp.domReady( () => {
	  // image
	  wp.blocks.unregisterBlockStyle('core/image', 'rounded')
	  wp.blocks.unregisterBlockStyle('core/image', 'default')
	  // quote
	  wp.blocks.unregisterBlockStyle('core/quote', 'default')
	  wp.blocks.unregisterBlockStyle('core/quote', 'large')
	  // button
	  wp.blocks.unregisterBlockStyle('core/button', 'fill')
	  wp.blocks.unregisterBlockStyle('core/button', 'outline')
	  // pullquote
	  wp.blocks.unregisterBlockStyle('core/pullquote', 'default')
	  wp.blocks.unregisterBlockStyle('core/pullquote', 'solid-color')
	  // separator
	  wp.blocks.unregisterBlockStyle('core/separator', 'default')
	  wp.blocks.unregisterBlockStyle('core/separator', 'wide')
	  wp.blocks.unregisterBlockStyle('core/separator', 'dots')
	  // table
	  wp.blocks.unregisterBlockStyle('core/table', 'regular')
	  wp.blocks.unregisterBlockStyle('core/table', 'stripes')
	  // social-links
	  wp.blocks.unregisterBlockStyle('core/social-links', 'default')
	  wp.blocks.unregisterBlockStyle('core/social-links', 'logos-only')
	  wp.blocks.unregisterBlockStyle('core/social-links', 'pill-shape')
  } )
EOF

cat > unregisterFormatType.js << EOF
  wp.domReady( () => {
	  // All blocks using RichText
      wp.richText.unregisterFormatType( 'core/text-color' )
	  wp.richText.unregisterFormatType( 'core/code' )
	  wp.richText.unregisterFormatType( 'core/keyboard' )
  } )
EOF
