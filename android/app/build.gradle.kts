import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // Must be applied after android/kotlin
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.cajed.in"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.cajed.in"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // signingConfigs {
    //     create("release") {
    //         val keystorePropertiesFile = rootProject.file("key.properties")
    //         val keystoreProperties = Properties()
    //         keystoreProperties.load(keystorePropertiesFile.inputStream())

    //         storeFile = file(keystoreProperties.getProperty("storeFile"))
    //         storePassword = keystoreProperties.getProperty("storePassword")
    //         keyAlias = keystoreProperties.getProperty("keyAlias")
    //         keyPassword = keystoreProperties.getProperty("keyPassword")
    //     }
    // }

    buildTypes {
        getByName("debug") {
            //signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
} 

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    implementation("org.slf4j:slf4j-simple:1.7.30")
}

flutter {
    source = "../.."
}
