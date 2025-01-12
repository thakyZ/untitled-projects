using namespace System.IO;
[CmdletBinding()]
Param()

Begin {
  [FileSystemInfo[]] $LatestWindowsClient = (Get-ChildItem -Path (Join-Path -Path $PWD -ChildPath 'luacsforbarotrauma-latest_build_windows_client'));

  [FileSystemInfo[]] $LatestWindowsServer = (Get-ChildItem -Path (Join-Path -Path $PWD -ChildPath 'luacsforbarotrauma-latest_build_windows_server'));

  [FileSystemInfo[]] $LuaForBarotrauma = (Get-ChildItem -Path (Join-Path -Path $PWD -ChildPath '2559634234-Lua_For_Barotrauma' -AdditionalChildPath @('Binary')));

  [FileSystemInfo[]] $LuaForBarotraumaXPath = (Get-ChildItem -Path (Join-Path -Path $PWD -ChildPath '2856758496-Lua_For_Barotrauma-with_xpath_patch' -AdditionalChildPath @('Binary')));

  [DirectoryInfo] $OutputDir = (Get-Item -Path (Join-Path -Path $PWD -ChildPath 'output'));

  [FileSystemInfo[]] $A = $LuaForBarotrauma;

  [FileSystemInfo[]]$B = $LatestWindowsClient;

  Function Get-BOfName {
    [CmdletBinding()]
    [OutputType([Hashtable])]
    Param(
      [Parameter(Mandatory = $True,
                 Position = 0,
                 HelpMessage = 'The name to apply to the output')]
      [string]
      $Name
      [Parameter(Mandatory = $True,
                 Position = 1,
                 ValueFromPipeline = $True,
                 HelpMessage = 'The b list property.')]
      [FileSystemInfo[]]
      $B
    )

    Begin {
      [HashTable] $Output = @{
        Name = $Name;
        FullName = (Join-Path -Path $B[10].Directory -ChildPath $Name);
        Directory = $B[10].Directory;
      };
    } End {
      Write-Output -NoEnumerate -InputObject $Output;
    }
  }
} Process {
  [Hashtable] $Output_A_Name     = @{ Name = "A_Name";     Expression = { $_.Name }; };
  [Hashtable] $Output_A_FullName = @{ Name = "A_FullName"; Expression = { $_.FullName }; };
  [Hashtable] $Output_B_Name     = @{ Name = "B_Name";     Expression = { (GetBOfName $_.Name).Name;     }; };
  [Hashtable] $Output_B_FullName = @{ Name = "B_FullName"; Expression = { (GetBOfName $_.Name).FullName; }; };

  [PSObject[]] $StuffNotInB = ($A | Where-Object { $B.Name -notcontains $_.Name } | Select-Object -Property $Output_A_Name,$Output_A_FullName,$Output_B_Name,$Output_B_FullName);
  If ($PSBoundParameter.ContainsKey('Debug')) {
    $StuffNotInB | ForEach-Object { Write-Host $_ });
  }

  [PSObject[]] $StuffInBAndA = ($A | Where-Object { $B.Name -contains $_.Name } | Select-Object -Property $Output_A_Name,$Output_A_FullName,$Output_B_Name,$Output_B_FullName);
  If ($PSBoundParameter.ContainsKey('Debug')) {
    $StuffInBAndA | ForEach-Object { Write-Host $_ });
  }

  If (-not $Failed) {
    ForEach ($Item in $StuffInBAndA) {
      Try {
        Copy-Item -Force -Recurse -LiteralPath $Item.B_Fullname -Destination (Join-Path -Path $OutputDir.FullName -ChildPath $Item.A_Name)
      } Catch {
        Write-Error -ErrorRecord $_;
        $Failed = $True;
        Break;
      }
    }
  }

  If (-not $Failed) {
    ForEach ($Item in $StuffNotInB) {
      Try {
        Copy-Item -Force -Recurse -LiteralPath $Item.A_Fullname -Destination (Join-Path -Path $OutputDir.FullName -ChildPath $Item.A_Name)
      } catch {
        Write-Error -ErrorRecord $_;
        $Failed = $True;
        Break;
      }
    }
  }
} End {
  If ($Failed) {
    Exit 1;
  }
}