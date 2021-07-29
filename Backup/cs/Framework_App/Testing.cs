using System.IO;


namespace App
{
    public class Testing
    {


        public void TestFModUpdate()
        {
            if (Directory.Exists(Manifest.UpdateDir))
            {
                Directory.Delete(Manifest.UpdateDir, true);
            }
            else
            {
                /*
                string verCfgFilePath = Manifest.PackageDir + Manifest.VerCfgFileName;
                string fullVersion = Manifest.GetFileText(verCfgFilePath);

                Directory.CreateDirectory(Manifest.UpdateDir);
                verCfgFilePath = Manifest.UpdateDir + Manifest.VerCfgFileName;
                File.Create(verCfgFilePath);
                File.WriteAllText(verCfgFilePath, fullVersion);

                string manifest = fullVersion + ".manifest";
                File.Copy(Manifest.PackageDir + manifest, Manifest.UpdateDir + manifest);
                */

                string bankName = "md5.bytes";
                File.Copy(Manifest.PackageDir + bankName, Manifest.UpdateDir + bankName);
                File.Delete(Manifest.PackageDir + bankName);
            }

            ShibaInu.LuaHelper.Relaunch();
        }


        //
    }
}

