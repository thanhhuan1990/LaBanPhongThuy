# Room instantiates generated *_Impl databases (e.g. WorkManager's WorkDatabase_Impl) via reflection.
-keep class * extends androidx.room.RoomDatabase { <init>(); }
