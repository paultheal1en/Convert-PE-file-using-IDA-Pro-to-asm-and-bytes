# Convert PE File using IDA Pro to ASM and Bytes

Công cụ chuyển đổi file PE thành ASM và bytes bằng IDA Pro với script PowerShell.

## Yêu cầu
- IDA Pro.
- Windows PowerShell (chạy Admin).

## Cài đặt
```powershell
Set-ExecutionPolicy Unrestricted
```

## Sử dụng 
```powershell
.\Generate-Samples.ps1 -InputDirectory C:\Path\To\Your\Input -OutputDirectory C:\Path\To\Your\Output
```
-InputDirectory: Thư mục file PE.

-OutputDirectory: Thư mục lưu kết quả.
