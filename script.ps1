Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$response1 = [System.Windows.Forms.MessageBox]::Show("Are you sure you want to open this?", "Hmm...", "YesNo", "Question")

if ($response1 -ne "Yes") { exit }

$response2 = [System.Windows.Forms.MessageBox]::Show("Are you REALLY sure?", "One more time...", "YesNo", "Warning")

if ($response2 -ne "Yes") { exit }

$form = New-Object Windows.Forms.Form
$form.FormBorderStyle = 'None'
$form.TopMost = $true
$form.Bounds = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
$form.ShowInTaskbar = $false

$form.BackColor = 'Magenta'
$form.TransparencyKey = 'Magenta'

$ws = Add-Type -MemberDefinition @"
[DllImport("user32.dll")]
public static extern int SetWindowLong(IntPtr hWnd, int nIndex, int dwNewLong);
[DllImport("user32.dll")]
public static extern int GetWindowLong(IntPtr hWnd, int nIndex);
"@ -Name "Win32Util" -Namespace Win32 -PassThru

$hwnd = $form.Handle
$style = $ws::GetWindowLong($hwnd, -20)
$ws::SetWindowLong($hwnd, -20, $style -bor 0x80000 -bor 0x20) 

$form.Add_KeyDown({
    if ($_.KeyCode -eq 'P') {
        $form.Close()
    }
})

$form.Show()

function Play-ErrorSoundSequence {
    $errorSoundSequence = @(
        [System.Media.SystemSounds]::Hand,
        [System.Media.SystemSounds]::Hand,
        [System.Media.SystemSounds]::Hand
    )
    
    foreach ($sound in $errorSoundSequence) {
        $sound.Play() 
        Start-Sleep -Milliseconds 500  
    }
}

$job = Start-Job -ScriptBlock {
    while ($true) {
        Play-ErrorSoundSequence
        Start-Sleep -Seconds 2 
    }
}

$graphics = $form.CreateGraphics()
$width = $form.Width
$height = $form.Height

while ($true) {
    $x = Get-Random -Minimum 0 -Maximum $width
    $y = Get-Random -Minimum 0 -Maximum $height
    $w = Get-Random -Minimum 20 -Maximum 200
    $h = Get-Random -Minimum 20 -Maximum 200

    $r = Get-Random -Minimum 0 -Maximum 256
    $g = Get-Random -Minimum 0 -Maximum 256
    $b = Get-Random -Minimum 0 -Maximum 256

    $brush = New-Object Drawing.SolidBrush ([Drawing.Color]::FromArgb($r, $g, $b))

    if ((Get-Random -Minimum 0 -Maximum 2) -eq 0) {
        $graphics.FillEllipse($brush, $x, $y, $w, $h)
    } else {
        $graphics.FillRectangle($brush, $x, $y, $w, $h)
    }

    Start-Sleep -Milliseconds 0
}

Stop-Job $job
Remove-Job $job
