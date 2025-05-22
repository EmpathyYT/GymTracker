# Keep Flutter framework classes
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }

-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.SplitInstallException
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManager
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManagerFactory
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest$Builder
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest
-dontwarn com.google.android.play.core.splitinstall.SplitInstallSessionState
-dontwarn com.google.android.play.core.splitinstall.SplitInstallStateUpdatedListener
-dontwarn com.google.android.play.core.tasks.OnFailureListener
-dontwarn com.google.android.play.core.tasks.OnSuccessListener
-dontwarn com.google.android.play.core.tasks.Task

# Keep native method names
-keepclasseswithmembernames class * {
  native <methods>;
}

# Keep Supabase SDK native classes (Firebase is not used but Supabase may have similar native SDKs)
-keep class io.supabase.** { *; }
-keep class io.supabase.flutter.** { *; }

# Keep App Links native classes
-keep class io.app_links.** { *; }

# Keep JSON serialization models (your own model package - replace with your actual package)
-keep class com.gym.tracker.gymtracker.** { *; }

# Keep JSON annotations (sometimes needed for reflection)
-keepattributes Signature
-keepattributes *Annotation*

# Optional: Keep model classes annotated with @JsonSerializable if using json_serializable
-keep class * implements com.fasterxml.jackson.databind.JsonSerializable { *; }
