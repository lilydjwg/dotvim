$signature = @'
using System;
using System.Runtime.InteropServices;

namespace Win32 {
public class Reg {

[DllImport("advapi32.dll", CharSet = CharSet.Unicode)]
public static extern int RegOpenKeyExW(int hKey, string lpSubKey, int ulOptions, uint samDesired, out IntPtr phkResult);

[DllImport("kernel32.dll", CharSet = CharSet.Unicode)]
public static extern IntPtr CreateEventW(int lpEventAttributes, bool bManualReset, bool bInitialState, string lpName);

[DllImport("advapi32.dll", CharSet = CharSet.Unicode)]
public static extern int RegNotifyChangeKeyValue(IntPtr hKey, bool bWatchSubtree, int dwNotifyFilter, IntPtr hEvent, bool fAsynchronous);

[DllImport("kernel32.dll", CharSet = CharSet.Unicode)]
public static extern int WaitForSingleObject(IntPtr hHandle, int dwMilliseconds);

[DllImport("advapi32.dll", CharSet = CharSet.Unicode)]
public static extern int CloseHandle(IntPtr hKey);

[DllImport("advapi32.dll", CharSet = CharSet.Unicode)]
public static extern int RegCloseKey(int hKey);

}
}
'@
$type = Add-Type -TypeDefinition $signature

$reg_key = "Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"

$hkey_current_user = 0x80000001
$key_notify = 0x0010
$reg_value_changed = 0x00000004L
$infinite = 0xFFFFFFFF
$handle = [IntPtr]::Zero

$result = [Win32.Reg]::RegOpenKeyExW($hkey_current_user, $reg_key, 0, $key_notify, [ref]$handle)
$event = [Win32.Reg]::CreateEventW($null, 1, 0, $null)

:Outer while (1) {
	$result = [Win32.Reg]::RegNotifyChangeKeyValue($handle, 0, $reg_value_changed, $event, 1)
	$wait = [Win32.Reg]::WaitForSingleObject($event, $infinite)

	switch ($wait) {
		$infinite { break Outer }
		0 {
			reg query "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v AppsUseLightTheme
		}
	}
}

[Win32.Reg]::CloseHandle($event)
[Win32.Reg]::RegCloseKey($handle)
