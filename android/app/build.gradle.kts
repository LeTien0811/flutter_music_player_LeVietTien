plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.offline_music_player"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // Vẫn giữ chuẩn 17 để tương thích thư viện
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        // Vẫn giữ chuẩn 17
        jvmTarget = "17"
    }

    // ĐÃ XÓA KHỐI java { toolchain ... } Ở ĐÂY ĐỂ TRÁNH LỖI TÌM JAVA

    defaultConfig {
        applicationId = "com.example.offline_music_player"

        // SỬA MIN SDK THÀNH 23
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
}

flutter {
    source = "../.."
}
