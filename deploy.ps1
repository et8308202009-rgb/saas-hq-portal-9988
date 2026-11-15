# SaaS 總部控制中心．一鍵部署（GitHub Pages）
$ErrorActionPreference = 'Continue'
try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch {}
Set-Location -LiteralPath $PSScriptRoot

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  總部控制中心  一鍵部署上線" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

try {
    git add -A 2>$null
    if ($LASTEXITCODE -ne 0) { throw "git add 失敗" }

    git diff --cached --quiet 2>$null
    $hasChanges = ($LASTEXITCODE -ne 0)

    if ($hasChanges) {
        $msg = "更新總部後台 " + (Get-Date -Format 'yyyy-MM-dd HH:mm')
        Write-Host "[1/3] 提交變更：$msg" -ForegroundColor Yellow
        $c = git commit -m $msg 2>&1
        if ($LASTEXITCODE -ne 0) { $c | ForEach-Object { Write-Host "      $_" -ForegroundColor DarkGray }; throw "git commit 失敗" }

        Write-Host "[2/3] 推送到 GitHub..." -ForegroundColor Yellow
        $p = git push 2>&1
        if ($LASTEXITCODE -ne 0) { $p | ForEach-Object { Write-Host "      $_" -ForegroundColor DarkGray }; throw "git push 失敗（請確認網路與 GitHub 登入狀態）" }
        Write-Host "      OK 已推送" -ForegroundColor Green
    } else {
        Write-Host "[1/3] 沒有任何變更，略過提交" -ForegroundColor DarkGray
        Write-Host "[2/3] 略過推送" -ForegroundColor DarkGray
    }

    Write-Host "[3/3] 等待 GitHub Pages 重新建置（約 60 秒）..." -ForegroundColor Yellow
    Start-Sleep -Seconds 60
    try {
        $r = Invoke-WebRequest 'https://et8308202009-rgb.github.io/saas-hq-portal-9988/' -UseBasicParsing -TimeoutSec 30
        Write-Host "線上狀態：HTTP $($r.StatusCode)  OK" -ForegroundColor Green
    } catch {
        Write-Host "線上檢查失敗：$($_.Exception.Message)" -ForegroundColor Red
    }

    Write-Host ""
    Write-Host "完成！總部網址：" -ForegroundColor Cyan
    Write-Host "https://et8308202009-rgb.github.io/saas-hq-portal-9988/" -ForegroundColor Cyan
} catch {
    Write-Host ""
    Write-Host "發生錯誤：$($_.Exception.Message)" -ForegroundColor Red
} finally {
    Write-Host ""
    Read-Host "按 Enter 關閉視窗" | Out-Null
}
