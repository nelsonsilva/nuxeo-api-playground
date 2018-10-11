const path = require('path')
const webpack = require('webpack')
const CleanWebpackPlugin = require('clean-webpack-plugin')
const CopyWebpackPlugin = require('copy-webpack-plugin')
const HtmlWebpackPlugin = require('html-webpack-plugin')

const TARGET = 'dist';

module.exports = {
  entry: {
    playground: './src/playground.ts',
    // semantic: './src/semantic.ts'
  },
  output: {
    filename: '[name].js',
    //chunkFilename: '[name].bundle.js',
    path: path.resolve(__dirname, TARGET)
  },
  resolve: {
    extensions: ['.ts', '.js']
  },
  mode: 'development',
  devtool: 'inline-source-map',
  module: {
    rules: [
      {
        test: /\.ts?$/,
        loader: 'ts-loader',
        exclude: /node_modules/
      },
      {
        test: /\.css$/,
        use: [
          'to-string-loader',
          'css-loader'
        ]
      },
      {
        test: /\.(png|jpg|gif|svg|eot|ttf|woff|woff2)$/,
        loader: 'url-loader',
        options: {
          limit: 10000
        }
      }
    ]
  },
  devServer: {
    contentBase: TARGET,
    port: 5000,
    host: '0.0.0.0',
    compress: true,
    historyApiFallback: true
  },
  optimization: {
    // splitChunks: {
    //   chunks: 'all'
    // }
  },
  plugins: [
    new CleanWebpackPlugin([TARGET]),
    //new HtmlWebpackPlugin({
    //  file: path.join(TARGET, 'index.html'),
    //  template: path.resolve('src/index.html')
    //}),
    new CopyWebpackPlugin([
      { from: 'index.html' },
      { from: 'favicon.ico' },
      { from: 'manifest.json' },
      { from: 'images', to: 'images' },
      { from: 'semantic/fonts', to: 'fonts' },
      {
        from: 'node_modules/@webcomponents/webcomponentsjs/*js',
        to: 'webcomponentsjs',
        flatten: true
      }
    ])
  ]
};

