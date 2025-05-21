# === Razorpay ProGuard Rules ===
-keep class com.razorpay.** { *; }
-keep interface com.razorpay.** { *; }
-dontwarn com.razorpay.**

# === Keep Google Pay/Tez classes used by Razorpay ===
-keep class com.google.android.apps.nbu.paisa.** { *; }
-dontwarn com.google.android.apps.nbu.paisa.**

# === Keep ProGuard Annotations (used by Razorpay and others) ===
-keep class proguard.annotation.Keep { *; }
-keep class proguard.annotation.KeepClassMembers { *; }
-dontwarn proguard.annotation.Keep
-dontwarn proguard.annotation.KeepClassMembers

# === Keep SLF4J classes to avoid StaticLoggerBinder errors ===
-keep class org.slf4j.impl.StaticLoggerBinder { *; }
-keep class org.slf4j.** { *; }
-dontwarn org.slf4j.**

# === Prevent R8 from stripping annotations and reflection metadata ===
-keepattributes *Annotation*, InnerClasses, Signature, EnclosingMethod

# === General fallback to preserve custom annotations (use cautiously) ===
-keep class * {
    @interface *;
}
