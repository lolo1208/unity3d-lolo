package shibaInu.util;

import java.io.File;
import java.lang.reflect.Method;

import android.content.Context;

import com.unity3d.player.UnityPlayer;

import dalvik.system.DexFile;


/**
 * 代理（反射）调用 SystemProperties 的相关方法
 * Created by LOLO on 2019/03/09.
 */
public final class SystemPropertiesProxy {

    /**
     * Get the value for the given key.
     *
     * @return if the key isn't found, return def if it isn't null, or an empty string otherwise
     * @throws IllegalArgumentException if the key exceeds 32 characters
     */
    public static String get(String key, String def, Context context) throws IllegalArgumentException {
        String ret;
        try {
            ClassLoader cl = context.getClassLoader();
            @SuppressWarnings("rawtypes")
            Class SystemProperties = cl.loadClass("android.os.SystemProperties");

            @SuppressWarnings("rawtypes")
            Class[] paramTypes = new Class[2];
            paramTypes[0] = String.class;
            paramTypes[1] = String.class;
            Object[] params = new Object[2];
            params[0] = new String(key);
            params[1] = new String(def);

            @SuppressWarnings("unchecked")
            Method get = SystemProperties.getMethod("get", paramTypes);
            ret = (String) get.invoke(SystemProperties, params);

        } catch (IllegalArgumentException iAE) {
            throw iAE;
        } catch (Exception e) {
            ret = def;
        }
        return ret;
    }

    public static String get(String key, String def) throws IllegalArgumentException {
        return get(key, def, UnityPlayer.currentActivity);
    }

    public static String get(String key) throws IllegalArgumentException {
        return get(key, "", UnityPlayer.currentActivity);
    }


    /**
     * Get the value for the given key, and return as an integer.
     *
     * @param key the key to lookup
     * @param def a default value to return
     * @return the key parsed as an integer, or def if the key isn't found or cannot be parsed
     * @throws IllegalArgumentException if the key exceeds 32 characters
     */
    public static Integer getInt(String key, int def, Context context) throws IllegalArgumentException {
        Integer ret;
        try {
            ClassLoader cl = context.getClassLoader();
            @SuppressWarnings("rawtypes")
            Class SystemProperties = cl.loadClass("android.os.SystemProperties");

            @SuppressWarnings("rawtypes")
            Class[] paramTypes = new Class[2];
            paramTypes[0] = String.class;
            paramTypes[1] = int.class;
            Object[] params = new Object[2];
            params[0] = new String(key);
            params[1] = new Integer(def);

            @SuppressWarnings("unchecked")
            Method getInt = SystemProperties.getMethod("getInt", paramTypes);
            ret = (Integer) getInt.invoke(SystemProperties, params);

        } catch (IllegalArgumentException iAE) {
            throw iAE;
        } catch (Exception e) {
            ret = def;
        }
        return ret;
    }

    public static Integer getInt(String key, int def) throws IllegalArgumentException {
        return getInt(key, def, UnityPlayer.currentActivity);
    }

    public static Integer getInt(String key) throws IllegalArgumentException {
        return getInt(key, 0, UnityPlayer.currentActivity);
    }


    /**
     * Get the value for the given key, and return as a long.
     *
     * @param key the key to lookup
     * @param def a default value to return
     * @return the key parsed as a long, or def if the key isn't found or cannot be parsed
     * @throws IllegalArgumentException if the key exceeds 32 characters
     */
    public static Long getLong(String key, long def, Context context) throws IllegalArgumentException {
        Long ret;
        try {
            ClassLoader cl = context.getClassLoader();
            @SuppressWarnings("rawtypes")
            Class SystemProperties = cl.loadClass("android.os.SystemProperties");

            @SuppressWarnings("rawtypes")
            Class[] paramTypes = new Class[2];
            paramTypes[0] = String.class;
            paramTypes[1] = long.class;
            Object[] params = new Object[2];
            params[0] = new String(key);
            params[1] = new Long(def);

            @SuppressWarnings("unchecked")
            Method getLong = SystemProperties.getMethod("getLong", paramTypes);
            ret = (Long) getLong.invoke(SystemProperties, params);

        } catch (IllegalArgumentException iAE) {
            throw iAE;
        } catch (Exception e) {
            ret = def;
        }
        return ret;
    }

    public static Long getLong(String key, long def) throws IllegalArgumentException {
        return getLong(key, def, UnityPlayer.currentActivity);
    }

    public static Long getLong(String key) throws IllegalArgumentException {
        return getLong(key, 0, UnityPlayer.currentActivity);
    }


    /**
     * Get the value for the given key, returned as a boolean.
     * Values 'n', 'no', '0', 'false' or 'off' are considered false.
     * Values 'y', 'yes', '1', 'true' or 'on' are considered true.
     * (case insensitive).
     * If the key does not exist, or has any other value, then the default
     * result is returned.
     *
     * @param key the key to lookup
     * @param def a default value to return
     * @return the key parsed as a boolean, or def if the key isn't found or is not able to be parsed as a boolean.
     * @throws IllegalArgumentException if the key exceeds 32 characters
     */
    public static Boolean getBoolean(String key, boolean def, Context context) throws IllegalArgumentException {
        Boolean ret;
        try {
            ClassLoader cl = context.getClassLoader();
            Class SystemProperties = cl.loadClass("android.os.SystemProperties");

            Class[] paramTypes = new Class[2];
            paramTypes[0] = String.class;
            paramTypes[1] = boolean.class;
            Object[] params = new Object[2];
            params[0] = new String(key);
            params[1] = new Boolean(def);

            @SuppressWarnings("unchecked")
            Method getBoolean = SystemProperties.getMethod("getBoolean", paramTypes);
            ret = (Boolean) getBoolean.invoke(SystemProperties, params);

        } catch (IllegalArgumentException iAE) {
            throw iAE;
        } catch (Exception e) {
            ret = def;
        }
        return ret;
    }

    public static Boolean getBoolean(String key, boolean def) throws IllegalArgumentException {
        return getBoolean(key, def, UnityPlayer.currentActivity);
    }

    public static Boolean getBoolean(String key) throws IllegalArgumentException {
        return getBoolean(key, false, UnityPlayer.currentActivity);
    }


    /**
     * Set the value for the given key.
     *
     * @throws IllegalArgumentException if the key exceeds 32 characters
     * @throws IllegalArgumentException if the value exceeds 92 characters
     */
    public static void set(String key, String val, Context context) throws IllegalArgumentException {
        try {
            @SuppressWarnings("unused")
            DexFile df = new DexFile(new File("/system/app/Settings.apk"));
            @SuppressWarnings("unused")
            ClassLoader cl = context.getClassLoader();
            @SuppressWarnings("rawtypes")
            Class SystemProperties = Class.forName("android.os.SystemProperties");

            @SuppressWarnings("rawtypes")
            Class[] paramTypes = new Class[2];
            paramTypes[0] = String.class;
            paramTypes[1] = String.class;
            Object[] params = new Object[2];
            params[0] = new String(key);
            params[1] = new String(val);

            @SuppressWarnings("unchecked")
            Method set = SystemProperties.getMethod("set", paramTypes);
            set.invoke(SystemProperties, params);

        } catch (IllegalArgumentException iAE) {
            throw iAE;
        } catch (Exception e) {
            e.printStackTrace();
        }
    }


    //
}