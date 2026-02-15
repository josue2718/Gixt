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


# ==============================
# PASOS CONFIGURAR FIREBASE iOS
# ==============================

# 1. Descargar archivo de Firebase
# Ir a Firebase Console
# Project Settings > Your Apps > iOS App
# Descargar:
# GoogleService-Info.plist


# 2. Abrir proyecto iOS en Xcode
open ios/Runner.xcworkspace


# 3. Pasar archivo GoogleService-Info.plist a Xcode
# En Xcode:
# Runner > Runner (carpeta)
# Arrastrar GoogleService-Info.plist
# Marcar:
# ✔ Copy items if needed
# ✔ Runner target


# 4. Configurar Signing
# Runner > Signing & Capabilities
# Seleccionar Team (Apple ID)
# Si no existe:
# Xcode > Settings > Accounts > Add Apple ID


# 5. Agregar Capabilities
# En Signing & Capabilities agregar:
# ✔ Push Notifications
# ✔ Background Modes
# Dentro de Background Modes marcar:
# ✔ Remote notifications


# 6. Instalar dependencias iOS
flutter clean
cd ios
pod install
cd ..


# 7. Inicializar Firebase en Flutter (main.dart)

# await Firebase.initializeApp();


# 8. Pedir permisos de notificaciones

# await FirebaseMessaging.instance.requestPermission(
#   alert: true,
#   badge: true,
#   sound: true,
# );


# 9. Obtener tokens

# String? apns = await FirebaseMessaging.instance.getAPNSToken();
# print("APNS: $apns");

# String? fcm = await FirebaseMessaging.instance.getToken();
# print("FCM: $fcm");


# 10. Ejecutar app
flutter run


# ==============================
# NOTAS IMPORTANTES
# ==============================

# Para obtener FCM en iOS necesitas:
# - Cuenta Apple Developer paga ($99/año)
# - Subir APNs Key (.p8) a Firebase Console

# Sin eso:
# APNS = OK
# FCM = NO FUNCIONA (normal)


# ==============================
# FIN
# ==============================

