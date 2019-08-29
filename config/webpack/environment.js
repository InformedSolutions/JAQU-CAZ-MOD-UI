const { environment } = require('@rails/webpacker');
const { source_path: sourcePath } = require('@rails/webpacker/package/config');
const { join } = require('path');
const erbLoader = {
  test: /\.erb$/,
  enforce: 'pre',
  loader: 'rails-erb-loader'
};

// skip adding random hash

const myFileOptions = {
    name(file) {
        if (file.includes(sourcePath)) {
            return 'media/[path][name].[ext]'
        }
        return 'media/[folder]/[name].[ext]'
    },
    context: join(sourcePath)
};

const fileLoader = environment.loaders.get('file').use.find(el => el.loader === 'file-loader');
fileLoader.options = myFileOptions;

environment.loaders.prepend('erb', erbLoader);
module.exports = environment;
