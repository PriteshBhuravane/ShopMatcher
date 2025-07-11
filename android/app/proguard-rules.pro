# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# If your project uses WebView with JS, uncomment the following
# and specify the fully qualified class name to the JavaScript interface
# class:
#-keepclassmembers class fqcn.of.javascript.interface.for.webview {
#   public *;
#}

# Uncomment this to preserve the line number information for
# debugging stack traces.
#-keepattributes SourceFile,LineNumberTable

# If you keep the line number information, uncomment this to
# hide the original source file name.
#-renamesourcefileattribute SourceFile

# Keep WebView related classes
-keep class * extends android.webkit.WebView { *; }
-keep class * extends android.webkit.WebViewClient { *; }
-keep class * extends android.webkit.WebChromeClient { *; }

# Keep Flutter WebView plugin classes
-keep class io.flutter.plugins.webviewflutter.** { *; }
-keep class com.pichillilorenzo.flutter_inappwebview.** { *; }

# Keep HTTP related classes
-keep class okhttp3.** { *; }
-keep class retrofit2.** { *; }