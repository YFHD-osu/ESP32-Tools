#�ާ@�L�{�Ѧ�: https://blog.jmaker.com.tw/chinese_oled/

$WindowWidth = (Get-Host).UI.RawUI.MaxWindowSize.Width
if ($WindowWidth%2 -eq 1){$WindowWidth -= 1}

function SelectInoList{
    param (
	  [string]$Title = '��ܧA���M�צW��',
	  [string]$SelectionLore = '�п�ܤW�����ܪ��ﶵ',
	  [array]$inoFiles,
	  [string]$titleBar = "="*(($WindowWidth - $Title.Length - [regex]::matches($Title, '[^A-z0-9&._\-!@`#$%^&*()_/\+,."'' {}=;<> `:]').count - 2)/2 )
    )
    Clear-Host
	
    Write-Host $titleBar $Title $titleBar
    Write-Host $WindowWidth
	for ($i=0; $i -lt $inoFiles.count; $i=$i+1 ) {
	  $displayNum = $i+1
	  $displayFileName = $inoFiles[$i].Name
	  Write-Host " $displayNum > $displayFileName" ;
	}
    Write-Host " Q > �Ө����ް�"
	Write-Host $titleBar $Title $titleBar
	
	$selection = Read-Host $SelectionLore
	if ($selection -eq 'Q') {return -1}
	if ($selection -eq '') {
	  SelectInoList -inoFiles $inoFiles
	  return
	}
	
	try {
	  [int]$selection = $selection
	  if ($selection -ge $inoFiles.count) {
	    SelectInoList -inoFiles $inoFiles -SelectionLore "'$selection' �W�X�F��ܽd��"
	  }
	}catch{
	  SelectInoList -SelectionLore "'$selection' ���O�@�Ӧ��Ī����" -inoFiles $inoFiles
	  return
	}
	
	[int]$selection = $selection
	return $selection - 1
}

function ShowAllChinese{
  param (
    [string]$Title = '�����쪺����r',
    [string]$titleBar = "="*(($WindowWidth - $Title.Length - [regex]::matches($Title, '[^A-z0-9&._\-!@`#$%^&*()_/\+,."'' {}=;<> `:]').count - 2)/2 ),
    [array]$ChineseList
  )
	
  Write-Host $titleBar $Title $titleBar

  for ($i = 0; $i -lt $chineseWords.groups.count; $i=$i+1){
    $tmpString = $chineseWords.groups[$i].value
    Write-Host -NoNewline " $tmpString "
	if (((($i+1)*4) % $WindowWidth) -le ($WindowWidth % 4)){ Write-Host ""}
  }
  
  Write-Host ""
  Write-Host $titleBar $Title $titleBar

  return
}

function CheckDownload{
  param (
    $ResetChineseMap = $true
  )
	
  if ((Test-Path -Path ��.\u8g2Files\��) -ne $true) {mkdir u8g2Files > $null}
	
  if ((Test-Path -Path ��.\u8g2Files\unifont.bdf�� -PathType Leaf) -ne $true) {
    $bdfconvURL = 'https://github.com/olikraus/u8g2/raw/master/tools/font/bdf/unifont.bdf'
    $Path=��.\u8g2Files\unifont.bdf��
    Write-Host " | ��������unifont.bdf�A���b�U��!"
    Invoke-WebRequest -URI $bdfconvURL -OutFile $Path
  }

  if ((Test-Path -Path ��.\u8g2Files\bdfconv.exe�� -PathType Leaf) -ne $true) {
    $bdfconvURL = 'https://github.com/olikraus/u8g2/raw/master/tools/font/bdfconv/bdfconv.exe'
    $Path=��.\u8g2Files\bdfconv.exe��
    Write-Host " | ��������bdfconv.exe�A���b�U��!"
    Invoke-WebRequest -URI $bdfconvURL -OutFile $Path
  }

  if ((Test-Path -Path ��.\u8g2Files\7x13.bdf�� -PathType Leaf) -ne $true) {
    $bdfconvURL = 'https://raw.githubusercontent.com/olikraus/u8g2/master/tools/font/bdf/7x13.bdf'
    $Path=��.\u8g2Files\7x13.bdf��
    Write-Host " | ��������7x13.bdf�A���b�U��!"
    Invoke-WebRequest -URI $bdfconvURL -OutFile $Path
  }
	
  if((Test-Path -Path ��.\u8g2Files\chinese1.map.BAK�� -PathType Leaf) -ne $true){
    $bdfconvURL = 'https://raw.githubusercontent.com/olikraus/u8g2/master/tools/font/build/chinese1.map'
    $Path=��.\u8g2Files\chinese1.map.BAK��
    Write-Host " | ��������chinese1.map�A���b�U��!"
    Invoke-WebRequest -URI $bdfconvURL -OutFile $Path
  }else{
	Write-Host " | ���b���schinese1.map!"
  }
  Copy-Item ".\u8g2Files\chinese1.map.BAK" -Destination ".\u8g2Files\chinese1.map" -Recurse
  
  return
}

function StartConvert{
  param (
    [string]$Title = '�ഫ��',
    [string]$titleBar = "="*(($WindowWidth - $Title.Length - [regex]::matches($Title, '[^A-z0-9&._\-!@`#$%^&*()_/\+,."'' {}=;<> `:]').count - 2)/2 ),
    [array]$ChineseList
  )
	
  Write-Host $titleBar $Title $titleBar

  for ($i = 0; $i -lt $chineseWords.groups.count ; $i = $i+1){
    $character = '${0:X},' -f [int][char]$chineseWords.groups[$i].value
    Add-Content ".\u8g2Files\chinese1.map" $character
  }
  ./u8g2Files/bdfconv.exe -v ./u8g2Files/unifont.bdf -b 0 -f 1 -M ./u8g2Files/chinese1.map -d ./u8g2Files/7x13.bdf -n ./u8g2Files/u8g2_font_unifont -o ./u8g2Files/u8g2_font_unifont.c
  
  Write-Host $titleBar $Title $titleBar
	
  Remove-Item ./bdf.tga
  
  return
}

function WriteFile{
  param (
    $user = $env:UserProfile,
    $u8g2FontsPath = ��$user\Documents\Arduino\libraries\U8g2\src\clib\u8g2_fonts.c��
  )

  $UnicodeArray = Get-Content -Path .\u8g2Files\u8g2_font_unifont.c -Raw -Encoding UTF8
  $arrayCount = [regex]::matches($UnicodeArray, '\[\d+\]')
  $arrayContext = [regex]::matches($UnicodeArray, '"\) [\s\S]+"')
  $WriteContext = "const uint8_t u8g2_font_unifont_t_chinese1 {0} U8G2_FONT_SECTION(`"u8g2_font_unifont_t_chinese1{1};" -f $arrayCount.groups[0].value, $arrayContext.groups[0].value

  [string]$u8g2FontsContext = Get-Content -Path $u8g2FontsPath -Raw
  [int64]$startPostion = $u8g2FontsContext.IndexOf('const uint8_t u8g2_font_unifont_t_chinese1[')
  [int64]$endPostion = $u8g2FontsContext.IndexOf('";',$startPostion)

  if (($startPostion -ne -1) -and ($endPostion -ne -1)){
    Write-Host " | �w�b u8g2_fonts.c �ɮפ���� u8g2_font_unifont_t_chinese1 �A�л\��..."
    [int]$removeCount = $endPostion - $startPostion + 2
    $u8g2FontsContext.Remove($startPostion,$removeCount).Insert($startPostion, $WriteContext) | Set-Content -Encoding UTF8 -Path $u8g2FontsPath #.Insert($startPostion,$WriteContext)
  }else{
    Write-Host " | �L�k�b u8g2_fonts.c �ɮפ���� u8g2_font_unifont_t_chinese1 �A�L�k�л\�ɮסA�]�\���s�w��u8g2�i�H�ѨM?"
    return
    # $u8g2FontsContext.Insert(40, $WriteContext) | Set-Content -Encoding UTF8 -Path ��$user\Documents\u8g2_fonts.c��
  }

  return
}

$inoFiles = @(Get-Childitem -Recurse -Filter *.ino | Select-Object Name,Extension -Unique)

$FileName = ""
if ( $inoFiles.count -gt 1 ){
  $select = SelectInoList -inoFiles $inoFiles
  $FileName = $inoFiles[$select].Name
}
else{
  $FileName = $inoFiles[0].Name
}
Write-Host " | �w����ɮ�: '$FileName'"
$raw = (Get-Content -Path .\$FileName -Raw -Encoding UTF8) -replace '\r?\n', ''
$chineseWords = [regex]::matches($raw, '[^A-z0-9&._\-!@`#$%^&*()_/\+,."'' {}=;<> `:]') | select -Unique

if ($chineseWords.count -ne 1) {
  ShowAllChinese -ChineseList $chineseWords
}else{
  Write-Host " | ��������ݭn��Ķ������r�A�{���Y�N�h�X!"
  return
}

CheckDownload
StartConvert -ChineseList $chineseWords

# $WriteContext | Set-Content -Encoding UTF8 -NoNewline -Path ��$user\Documents\u8g2_fonts.c�� 

$user = $env:UserProfile
if ((Test-Path -Path $user\Documents\Arduino\libraries\U8g2\src\clib\u8g2_fonts.c -PathType Leaf) -eq $true) {
  Write-Host " | �w�b�w�]��Ƨ������: u8g2_fonts.c"
  WriteFile
}else{
  Write-Host " | ���b�w�]��Ƨ������: u8g2_fonts.c"
  while($true){
    Write-Host " | �Ф�ʩw�� u8g2_fonts.c ����m (�q�`�b ...\Arduino\libraries\U8g2\src\clib\u8g2_fonts.c)"
    $customPath = Read-Host "�п�J��󪺧����m�αN���즲�ܦ�����"
    if ((Test-Path -Path $customPath) -eq $true){
      WriteFile -u8g2FontsPath $customPath
      break
    }
  }
}

Write-Host u8g2_font_unifont_t_chinese1

#Write-Host $arrayCount
#Write-Host $arrayContext