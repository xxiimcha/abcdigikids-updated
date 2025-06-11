# Flutter and Dart related
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Firebase related
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# Speech to Text and Audio Plugins
-keep class com.csdcorp.speech_to_text.** { *; }
-keep class xyz.luan.audioplayers.** { *; }

# Required annotations and metadata
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-keepattributes Signature

# Prevent removal of any Activity or Service
-keep public class * extends android.app.Activity
-keep public class * extends android.app.Service

# General Kotlin compatibility
-dontwarn kotlin.**
-dontwarn kotlinx.coroutines.**

# Optional: allow reflection use
-keepclassmembers class * {
    @androidx.annotation.Keep *;
}
