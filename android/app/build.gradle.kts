plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.myfuture_application"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11

        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.myfuture_application"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
} // <--- THIS CLOSING BRACKET WAS MISSING

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}

// --- PLACE THE FIX HERE (Outside the android block) ---
configurations.all {
    resolutionStrategy {
        // 1. Fix error Activity (Yang mula-mula tadi)
        force("androidx.activity:activity:1.9.3")
        force("androidx.activity:activity-ktx:1.9.3")

        // 2. Fix error Browser (Yang baru keluar: 1.9.0 -> 1.8.0)
        force("androidx.browser:browser:1.8.0")

        // 3. Fix error Core (Yang baru keluar: 1.17.0 -> 1.15.0)
        force("androidx.core:core:1.15.0")
        force("androidx.core:core-ktx:1.15.0")
    }
}
// -----------------------------------------------------

flutter {
    source = "../.."
}