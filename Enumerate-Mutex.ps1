<#
.SYNOPSIS
    Enumerates named mutex (Mutant) kernel objects via Windows native APIs.

.DESCRIPTION
    This script compiles and runs embedded C# to interface with ntdll.dll,
    traversing the \ObjectManager namespace and locating mutexes (aka mutants).
    Original source: https://web.archive.org/web/20160110122741/http://alienvault-labs-garage.googlecode.com/svn/trunk/EnumerateMutex.cs

.NOTES
    Requires PowerShell running as administrator.
    The output lists named kernel objects of type "Mutant" (mutexes).
#>

Add-Type -TypeDefinition @"
using System;
using System.Collections;
using System.Runtime.InteropServices;
using Microsoft.Win32.SafeHandles;

public class MutexEnumerator
{
    [StructLayout(LayoutKind.Sequential)]
    public struct UNICODE_STRING : IDisposable
    {
        public ushort Length;
        public ushort MaximumLength;
        private IntPtr buffer;

        public UNICODE_STRING(string s)
        {
            Length = (ushort)(s.Length * 2);
            MaximumLength = (ushort)(Length + 2);
            buffer = Marshal.StringToHGlobalUni(s);
        }

        public void Dispose()
        {
            Marshal.FreeHGlobal(buffer);
            buffer = IntPtr.Zero;
        }

        public override string ToString()
        {
            return Marshal.PtrToStringUni(buffer);
        }
    }

    [StructLayout(LayoutKind.Sequential)]
    public struct OBJECT_ATTRIBUTES : IDisposable
    {
        public int Length;
        public IntPtr RootDirectory;
        private IntPtr objectName;
        public uint Attributes;
        public IntPtr SecurityDescriptor;
        public IntPtr SecurityQualityOfService;

        public OBJECT_ATTRIBUTES(string name, uint attrs)
        {
            Length = 0;
            RootDirectory = IntPtr.Zero;
            objectName = IntPtr.Zero;
            Attributes = attrs;
            SecurityDescriptor = IntPtr.Zero;
            SecurityQualityOfService = IntPtr.Zero;
            Length = Marshal.SizeOf(this);
            ObjectName = new UNICODE_STRING(name);
        }

        public UNICODE_STRING ObjectName
        {
            get => Marshal.PtrToStructure<UNICODE_STRING>(objectName);
            set
            {
                if (objectName == IntPtr.Zero)
                    objectName = Marshal.AllocHGlobal(Marshal.SizeOf(value));
                Marshal.StructureToPtr(value, objectName, false);
            }
        }

        public void Dispose()
        {
            if (objectName != IntPtr.Zero)
            {
                Marshal.DestroyStructure<UNICODE_STRING>(objectName);
                Marshal.FreeHGlobal(objectName);
                objectName = IntPtr.Zero;
            }
        }
    }

    [StructLayout(LayoutKind.Sequential)]
    public struct OBJECT_DIRECTORY_INFORMATION
    {
        public UNICODE_STRING Name;
        public UNICODE_STRING TypeName;
    }

    [DllImport("ntdll.dll")]
    public static extern int NtOpenDirectoryObject(out SafeFileHandle DirectoryHandle, uint DesiredAccess, ref OBJECT_ATTRIBUTES ObjectAttributes);

    [DllImport("ntdll.dll")]
    public static extern int NtQueryDirectoryObject(SafeFileHandle DirectoryHandle, IntPtr Buffer, int Length, bool ReturnSingleEntry, bool RestartScan, ref uint Context, out uint ReturnLength);

    public static void Enumerate()
    {
        var entries = new ArrayList { "\\" };
        while (entries.Count > 0)
        {
            string entry = (string)entries[0];
            entries.RemoveAt(0);

            using var attr = new OBJECT_ATTRIBUTES(entry, 0);
            if (NtOpenDirectoryObject(out var h, 1, ref attr) < 0)
                continue;

            IntPtr buf = Marshal.AllocHGlobal(1024);
            uint context = 0, len;

            while (true)
            {
                int status = NtQueryDirectoryObject(h, buf, 1024, true, context == 0, ref context, out len);
                if (status < 0) break;

                var odi = Marshal.PtrToStructure<OBJECT_DIRECTORY_INFORMATION>(buf);
                string typeName = odi.TypeName.ToString();
                string name = odi.Name.ToString();

                if (typeName == "Mutant")
                    Console.WriteLine($"[Mutant] {entry}\\{name}");

                if (typeName == "Directory")
                    entries.Add(entry == "\\" ? $"{entry}{name}" : $"{entry}\\{name}");
            }

            Marshal.FreeHGlobal(buf);
            h.Dispose();
        }
    }
}
"@ -Language CSharp

# Call the method
[MutexEnumerator]::Enumerate()
