# Razorpay ProGuard rules
-keep class com.razorpay.** { *; }

# Keep ProGuard annotations (needed by Razorpay and other libraries)
-keep class proguard.annotation.Keep { *; }
-keep class proguard.annotation.KeepClassMembers { *; }

# Keep the slf4j logger classes
-keep class org.slf4j.impl.StaticLoggerBinder { *; }
