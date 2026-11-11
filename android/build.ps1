# Gece Nöbeti Android APK derleme betiği (Gradle gerekmez).
# Gerekenler: JDK 17, Android SDK (platforms;android-34, build-tools;34.0.0) ve bir imza anahtarı.
# Kullanım: .\build.ps1 -Jdk <jdk klasörü> -Sdk <sdk klasörü> -Keystore <dosya> -StorePass <şifre> -Out <çıktı klasörü>
param(
  [Parameter(Mandatory=$true)][string]$Jdk,
  [Parameter(Mandatory=$true)][string]$Sdk,
  [Parameter(Mandatory=$true)][string]$Keystore,
  [Parameter(Mandatory=$true)][string]$StorePass,
  [Parameter(Mandatory=$true)][string]$Out
)
$ErrorActionPreference = 'Stop'
$A    = $PSScriptRoot                    # android klasörü
$Web  = Split-Path $A -Parent            # oyun dosyaları (depo kökü)
$BT   = "$Sdk\build-tools\34.0.0"
$JAR  = "$Sdk\platforms\android-34\android.jar"
$env:JAVA_HOME = $Jdk; $env:Path = "$Jdk\bin;$env:Path"

if (Test-Path $Out) { Remove-Item -Recurse -Force $Out }
New-Item -ItemType Directory -Force "$Out\res","$Out\gen","$Out\classes","$Out\dex" | Out-Null

& "$BT\aapt2.exe" compile --dir "$A\res" -o "$Out\res\res.zip"; if ($LASTEXITCODE) { throw 'aapt2 compile' }
& "$BT\aapt2.exe" link -o "$Out\base.apk" -I $JAR --manifest "$A\AndroidManifest.xml" --java "$Out\gen" "$Out\res\res.zip" --auto-add-overlay; if ($LASTEXITCODE) { throw 'aapt2 link' }

$srcs = Get-ChildItem "$A\src","$Out\gen" -Recurse -Filter *.java | % FullName
& "$Jdk\bin\javac.exe" -source 8 -target 8 -nowarn -encoding UTF-8 -classpath $JAR -d "$Out\classes" $srcs; if ($LASTEXITCODE) { throw 'javac' }
$cls = Get-ChildItem "$Out\classes" -Recurse -Filter *.class | % FullName
& "$BT\d8.bat" --release --min-api 24 --lib $JAR --output "$Out\dex" $cls; if ($LASTEXITCODE) { throw 'd8' }

# dex ve oyun dosyalarını (internetsiz yedek) APK'ya ekle; yollar düz eğik çizgiyle yazılır
Copy-Item "$Out\base.apk" "$Out\unsigned.apk"
Add-Type -AssemblyName System.IO.Compression.FileSystem
$z = [IO.Compression.ZipFile]::Open("$Out\unsigned.apk", 'Update')
[IO.Compression.ZipFileExtensions]::CreateEntryFromFile($z, "$Out\dex\classes.dex", 'classes.dex') | Out-Null
$skip = @('android', '.git')
foreach ($f in Get-ChildItem $Web -Recurse -File) {
  $rel = $f.FullName.Substring($Web.Length + 1).Replace('\', '/')
  if ($skip -contains $rel.Split('/')[0] -or $rel -eq '.nojekyll' -or $rel -like '*.md') { continue }
  [IO.Compression.ZipFileExtensions]::CreateEntryFromFile($z, $f.FullName, 'assets/' + $rel) | Out-Null
}
$z.Dispose()

& "$BT\zipalign.exe" -f -p 4 "$Out\unsigned.apk" "$Out\aligned.apk"; if ($LASTEXITCODE) { throw 'zipalign' }
& "$BT\apksigner.bat" sign --ks $Keystore --ks-pass "pass:$StorePass" --key-pass "pass:$StorePass" --out "$Out\GeceNobeti.apk" "$Out\aligned.apk"; if ($LASTEXITCODE) { throw 'apksigner' }
& "$BT\apksigner.bat" verify "$Out\GeceNobeti.apk"; if ($LASTEXITCODE) { throw 'verify' }
Get-Item "$Out\GeceNobeti.apk" | Select-Object Name, Length
