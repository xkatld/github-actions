#!/bin/bash

set +e
export LANG=C.UTF-8
export LC_ALL=C.UTF-8

echo "============================================="
echo "GitHub Actions 完整磁盘扫描工具"
echo "============================================="
echo "扫描时间: $(date '+%Y-%m-%d %H:%M:%S')"
echo "生成完整报告中，请稍候..."
echo ""

REPORT="/tmp/disk_full_report.txt"
> "$REPORT"

log_section() {
    echo "" | tee -a "$REPORT"
    echo "=============================================" | tee -a "$REPORT"
    echo "$1" | tee -a "$REPORT"
    echo "=============================================" | tee -a "$REPORT"
}

log_msg() {
    echo "$1" | tee -a "$REPORT"
}

# ============================================
# 1. 系统概览
# ============================================
log_section "1. 系统磁盘概览"
df -h | tee -a "$REPORT"
log_msg ""
log_msg "内存使用："
free -h | tee -a "$REPORT"

# ============================================
# 2. 全盘扫描 - /usr 目录（>10MB）
# ============================================
log_section "2. /usr 目录扫描（>10MB）"
log_msg "正在扫描 /usr ..."
sudo du -h --max-depth=1 /usr 2>/dev/null | awk '$1 ~ /[0-9]+M|[0-9]+G/ {
    size=$1; gsub(/M/, "", size); gsub(/G/, "", size);
    if ($1 ~ /G/ && size+0 > 0) print $0;
    else if ($1 ~ /M/ && size+0 >= 10) print $0;
}' | sort -hr >> "$REPORT"
log_msg ""
log_msg "=== /usr 二级目录（>10MB） ==="
sudo du -h --max-depth=2 /usr 2>/dev/null | awk '$1 ~ /[0-9]+M|[0-9]+G/ {
    size=$1; gsub(/M/, "", size); gsub(/G/, "", size);
    if ($1 ~ /G/ && size+0 > 0) print $0;
    else if ($1 ~ /M/ && size+0 >= 10) print $0;
}' | sort -hr >> "$REPORT"

# ============================================
# 3. /usr/share 详细扫描
# ============================================
log_section "3. /usr/share 详细扫描（>10MB）"
log_msg "正在扫描 /usr/share ..."
sudo du -h --max-depth=2 /usr/share 2>/dev/null | awk '$1 ~ /[0-9]+M|[0-9]+G/ {
    size=$1; gsub(/M/, "", size); gsub(/G/, "", size);
    if ($1 ~ /G/ && size+0 > 0) print $0;
    else if ($1 ~ /M/ && size+0 >= 10) print $0;
}' | sort -hr >> "$REPORT"

# ============================================
# 4. /usr/lib 详细扫描
# ============================================
log_section "4. /usr/lib 详细扫描（>10MB）"
log_msg "正在扫描 /usr/lib ..."
sudo du -h --max-depth=2 /usr/lib 2>/dev/null | awk '$1 ~ /[0-9]+M|[0-9]+G/ {
    size=$1; gsub(/M/, "", size); gsub(/G/, "", size);
    if ($1 ~ /G/ && size+0 > 0) print $0;
    else if ($1 ~ /M/ && size+0 >= 10) print $0;
}' | sort -hr >> "$REPORT"

# ============================================
# 5. /usr/local 详细扫描
# ============================================
log_section "5. /usr/local 详细扫描（>10MB）"
log_msg "正在扫描 /usr/local ..."
sudo du -h --max-depth=3 /usr/local 2>/dev/null | awk '$1 ~ /[0-9]+M|[0-9]+G/ {
    size=$1; gsub(/M/, "", size); gsub(/G/, "", size);
    if ($1 ~ /G/ && size+0 > 0) print $0;
    else if ($1 ~ /M/ && size+0 >= 10) print $0;
}' | sort -hr >> "$REPORT"

# ============================================
# 6. /opt 详细扫描
# ============================================
log_section "6. /opt 目录详细扫描（>10MB）"
log_msg "正在扫描 /opt ..."
sudo du -h --max-depth=3 /opt 2>/dev/null | awk '$1 ~ /[0-9]+M|[0-9]+G/ {
    size=$1; gsub(/M/, "", size); gsub(/G/, "", size);
    if ($1 ~ /G/ && size+0 > 0) print $0;
    else if ($1 ~ /M/ && size+0 >= 10) print $0;
}' | sort -hr >> "$REPORT"

# ============================================
# 7. /var 详细扫描
# ============================================
log_section "7. /var 目录详细扫描（>10MB）"
log_msg "正在扫描 /var ..."
sudo du -h --max-depth=3 /var 2>/dev/null | awk '$1 ~ /[0-9]+M|[0-9]+G/ {
    size=$1; gsub(/M/, "", size); gsub(/G/, "", size);
    if ($1 ~ /G/ && size+0 > 0) print $0;
    else if ($1 ~ /M/ && size+0 >= 10) print $0;
}' | sort -hr >> "$REPORT"

# ============================================
# 8. /home 详细扫描
# ============================================
log_section "8. /home 目录详细扫描（>10MB）"
log_msg "正在扫描 /home ..."
sudo du -h --max-depth=3 /home 2>/dev/null | awk '$1 ~ /[0-9]+M|[0-9]+G/ {
    size=$1; gsub(/M/, "", size); gsub(/G/, "", size);
    if ($1 ~ /G/ && size+0 > 0) print $0;
    else if ($1 ~ /M/ && size+0 >= 10) print $0;
}' | sort -hr >> "$REPORT"

# ============================================
# 9. /tmp 和临时文件
# ============================================
log_section "9. /tmp 临时文件（>10MB）"
log_msg "正在扫描 /tmp ..."
sudo du -h --max-depth=2 /tmp 2>/dev/null | awk '$1 ~ /[0-9]+M|[0-9]+G/ {
    size=$1; gsub(/M/, "", size); gsub(/G/, "", size);
    if ($1 ~ /G/ && size+0 > 0) print $0;
    else if ($1 ~ /M/ && size+0 >= 10) print $0;
}' | sort -hr >> "$REPORT"

# ============================================
# 10. /snap 目录
# ============================================
log_section "10. /snap 目录（>10MB）"
if [ -d /snap ]; then
    log_msg "正在扫描 /snap ..."
    sudo du -h --max-depth=2 /snap 2>/dev/null | awk '$1 ~ /[0-9]+M|[0-9]+G/ {
        size=$1; gsub(/M/, "", size); gsub(/G/, "", size);
        if ($1 ~ /G/ && size+0 > 0) print $0;
        else if ($1 ~ /M/ && size+0 >= 10) print $0;
    }' | sort -hr >> "$REPORT"
else
    log_msg "/snap 目录不存在"
fi

# ============================================
# 11. APT 包管理器
# ============================================
log_section "11. APT 已安装软件包（完整列表）"
log_msg "正在列出所有已安装的 APT 包..."
    dpkg-query -Wf '${Installed-Size}\t${Package}\n' 2>/dev/null | \
        sort -rn | \
    awk '{printf "%10.2f MB  %s\n", $1/1024, $2}' >> "$REPORT"

# ============================================
# 12. APT 缓存
# ============================================
log_section "12. APT 缓存目录（完整）"
if [ -d /var/cache/apt ]; then
    log_msg "APT 缓存详情："
    sudo du -h --max-depth=2 /var/cache/apt 2>/dev/null | sort -hr >> "$REPORT"
fi

# ============================================
# 13. 日志文件
# ============================================
log_section "13. 系统日志文件（完整）"
if [ -d /var/log ]; then
    log_msg "正在扫描 /var/log ..."
    sudo du -h --max-depth=2 /var/log 2>/dev/null | sort -hr >> "$REPORT"
fi

# ============================================
# 14. Docker 相关
# ============================================
log_section "14. Docker 详细信息"
if command -v docker &> /dev/null; then
    log_msg "Docker 系统占用："
    docker system df 2>/dev/null >> "$REPORT" || log_msg "Docker 未运行"
    log_msg ""
    log_msg "Docker 镜像列表："
    docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" 2>/dev/null >> "$REPORT" || log_msg "无法获取"
    log_msg ""
    log_msg "Docker 容器列表："
    docker ps -a --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Size}}" 2>/dev/null >> "$REPORT" || log_msg "无法获取"
else
    log_msg "Docker 未安装"
fi

if [ -d /var/lib/docker ]; then
    log_msg ""
    log_msg "Docker 数据目录详情："
    sudo du -h --max-depth=2 /var/lib/docker 2>/dev/null | sort -hr >> "$REPORT"
fi

# ============================================
# 15. 内核和模块
# ============================================
log_section "15. 内核和模块"
if [ -d /lib/modules ]; then
    log_msg "内核模块目录："
    sudo du -h --max-depth=1 /lib/modules 2>/dev/null | sort -hr >> "$REPORT"
fi

if [ -d /usr/src ]; then
    log_msg ""
    log_msg "源码目录："
    sudo du -h --max-depth=1 /usr/src 2>/dev/null | sort -hr >> "$REPORT"
fi

# ============================================
# 16. 文档和手册（完整，不限大小）
# ============================================
log_section "16. 文档和手册完整扫描"
log_msg "手册页目录（完整）："
if [ -d /usr/share/man ]; then
    sudo du -h --max-depth=2 /usr/share/man 2>/dev/null | sort -hr >> "$REPORT"
fi

log_msg ""
log_msg "文档目录（完整）："
if [ -d /usr/share/doc ]; then
    sudo du -h --max-depth=2 /usr/share/doc 2>/dev/null | sort -hr >> "$REPORT"
fi

log_msg ""
log_msg "本地文档（完整）："
if [ -d /usr/local/doc ]; then
    sudo du -h --max-depth=1 /usr/local/doc 2>/dev/null | sort -hr >> "$REPORT"
fi

log_msg ""
log_msg "信息页（完整）："
if [ -d /usr/share/info ]; then
    sudo du -h /usr/share/info 2>/dev/null >> "$REPORT"
fi

# ============================================
# 17. 多语言支持（完整，不限大小）
# ============================================
log_section "17. 多语言和本地化文件（完整）"
if [ -d /usr/share/locale ]; then
    log_msg "语言包总大小："
    sudo du -sh /usr/share/locale 2>/dev/null >> "$REPORT"
    log_msg ""
    log_msg "所有语言包（完整列表）："
    sudo du -h --max-depth=1 /usr/share/locale 2>/dev/null | sort -hr >> "$REPORT"
fi

if [ -d /usr/share/i18n ]; then
    log_msg ""
    log_msg "国际化数据（完整）："
    sudo du -h --max-depth=1 /usr/share/i18n 2>/dev/null >> "$REPORT"
fi

# ============================================
# 18. 字体文件（完整，不限大小）
# ============================================
log_section "18. 字体文件（完整）"
if [ -d /usr/share/fonts ]; then
    log_msg "字体目录（完整）："
    sudo du -h --max-depth=2 /usr/share/fonts 2>/dev/null | sort -hr >> "$REPORT"
fi

# ============================================
# 19. 用户缓存目录（完整，不限大小）
# ============================================
log_section "19. 用户缓存目录（完整）"
for homedir in /home/* /root; do
    if [ -d "$homedir" ]; then
        log_msg ""
        log_msg "=== $homedir ==="
        
        # .cache
        if [ -d "$homedir/.cache" ]; then
            log_msg ".cache 目录（完整）："
            sudo du -h --max-depth=2 "$homedir/.cache" 2>/dev/null | sort -hr >> "$REPORT"
        fi
        
        # 各种语言的缓存（详细扫描）
        for cache_dir in .npm .cargo .rustup .go .gradle .m2 .ivy2 .sbt .pip .composer .local; do
            if [ -d "$homedir/$cache_dir" ]; then
                size=$(sudo du -sh "$homedir/$cache_dir" 2>/dev/null | awk '{print $1}')
                log_msg "$cache_dir: $size"
                # 如果目录较大，显示子目录
                if [ -n "$size" ]; then
                    sudo du -h --max-depth=1 "$homedir/$cache_dir" 2>/dev/null | sort -hr | head -10 >> "$REPORT"
                fi
            fi
        done
    fi
done

# ============================================
# 20. Snap 详细信息（完整）
# ============================================
log_section "20. Snap 详细信息（完整）"
if command -v snap &> /dev/null; then
    log_msg "已安装的 Snap 包："
    snap list 2>/dev/null >> "$REPORT" || log_msg "无权限或无包"
    log_msg ""
fi

if [ -d /var/lib/snapd ]; then
    log_msg "Snapd 数据目录详情（完整）："
    sudo du -h --max-depth=2 /var/lib/snapd 2>/dev/null | sort -hr >> "$REPORT"
fi

# ============================================
# 21. 大文件搜索（所有>50MB）
# ============================================
log_section "21. 大文件搜索（>50MB）"
log_msg "正在搜索所有大于 50MB 的文件..."
sudo find / -type f -size +50M \
    -not -path "/proc/*" \
    -not -path "/sys/*" \
    -not -path "/dev/*" \
    -exec ls -lh {} \; 2>/dev/null | \
    awk '{printf "%-10s %s\n", $5, $9}' | \
    sort -hr >> "$REPORT"

# ============================================
# 22. 特定软件检测
# ============================================
log_section "22. 特定软件和工具检测"

check_paths=(
    "/usr/share/dotnet:.NET SDK"
    "/usr/local/lib/android:Android SDK"
    "/usr/share/swift:Swift"
    "/usr/local/go:Go"
    "/usr/local/julia1.11.7:Julia"
    "/usr/share/miniconda:Miniconda"
    "/usr/local/.ghcup:GHCup"
    "/opt/ghc:GHC"
    "/usr/lib/jvm:Java JVM"
    "/usr/lib/llvm-16:LLVM 16"
    "/usr/lib/llvm-17:LLVM 17"
    "/usr/lib/llvm-18:LLVM 18"
    "/usr/lib/llvm-19:LLVM 19"
    "/usr/lib/llvm-20:LLVM 20"
    "/opt/hostedtoolcache:GitHub 工具缓存"
    "/opt/az:Azure CLI"
    "/usr/lib/google-cloud-sdk:Google Cloud SDK"
    "/usr/local/aws-cli:AWS CLI"
    "/usr/local/aws-sam-cli:AWS SAM CLI"
    "/usr/local/share/powershell:PowerShell"
    "/opt/microsoft:Microsoft 软件"
    "/usr/lib/firefox:Firefox"
    "/opt/google/chrome:Google Chrome"
    "/usr/local/share/chromium:Chromium"
    "/etc/skel/.cargo:Rust Cargo"
    "/usr/local/n:Node 版本管理器"
    "/opt/pipx:Pipx"
    "/opt/actionarchivecache:Action Archive Cache"
    "/opt/runner-cache:Runner Cache"
)

for item in "${check_paths[@]}"; do
    IFS=':' read -r path name <<< "$item"
    if [ -d "$path" ] || [ -f "$path" ]; then
        size=$(sudo du -sh "$path" 2>/dev/null | awk '{print $1}')
        log_msg "[存在] $name: $size ($path)"
    else
        log_msg "[不存在] $name"
    fi
done

# ============================================
# 23. 总结统计
# ============================================
log_section "23. 总结统计"

log_msg "根目录占用分析："
sudo du -h --max-depth=1 / 2>/dev/null | sort -hr >> "$REPORT"

log_msg ""
log_msg "当前磁盘使用："
df -h / >> "$REPORT"

log_msg ""
log_msg "内存使用："
free -h >> "$REPORT"

# ============================================
# 完成
# ============================================
echo ""
echo "============================================="
echo "✓ 扫描完成！"
echo "============================================="
echo ""
echo "完整报告已保存到: $REPORT"
echo "文件大小: $(ls -lh $REPORT | awk '{print $5}')"
echo ""
echo "查看报告:"
echo "  cat $REPORT"
echo "  less $REPORT"
echo "  grep -i '关键词' $REPORT"
echo ""
echo "建议："
echo "  1. 仔细查看报告中的所有目录"
echo "  2. 找出所有可以删除的内容"
echo "  3. 更新 balanced.yml 和 maximum.yml"
echo ""
