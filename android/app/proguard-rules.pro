-dontwarn proguard.annotation.Keep
-dontwarn proguard.annotation.KeepClassMembers
-keep class com.razorpay.** { *; }
-keep interface com.razorpay.** { *; }
# Keep Google Pay/Tez classes used by Razorpay
-keep class com.google.android.apps.nbu.paisa.** { *; }
-dontwarn com.google.android.apps.nbu.paisa.**


# Fix reflection-based R8 removals
-keepattributes *Annotation*, InnerClasses, Signature, EnclosingMethod

# Keep SLF4J classes
-keep class org.slf4j.** { *; }
-dontwarn org.slf4j.**