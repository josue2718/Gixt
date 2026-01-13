brew install rbenv ruby-build

echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.zshrc
echo 'eval "$(rbenv init - zsh)"' >> ~/.zshrc
source ~/.zshrc


rbenv --version

rbenv install 3.0.6
rbenv global 3.0.6
ruby -v

gem install ffi -v 1.17.3
gem install cocoapods
pod --version
cd ios
pod install

flutter clean
flutter pub get
cd ios
pod install
cd ..
flutter run
