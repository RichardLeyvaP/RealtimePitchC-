import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    // Llamar a la función C++ y mostrar el resultado en la consola
    let cppWrapper = CppWrapper()
    print(cppWrapper.getMessageFromCpp())

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

// Clase que actúa como puente entre Swift y C++
class CppWrapper {
    func getMessageFromCpp() -> String {
        return String(cString: stringFromCpp())
    }
}
