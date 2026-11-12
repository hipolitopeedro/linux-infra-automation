# 🐧 Linux Infrastructure Automation Toolkit

![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)
![Bash](https://img.shields.io/badge/Bash%20%2F%20Shell-121011?style=for-the-badge&logo=gnu-bash&logoColor=white)

> 🇺🇸 **English:** Collection of Bash scripts for Linux server administration, automated backup rotation with integrity verification, service auto-healing watchdog, and system health/security auditing.
>
> 🇧🇷 **Português:** Conjunto de scripts em Bash para administração de servidores Linux, rotação de backups automatizados com verificação de integridade, watchdog para recuperação automática de serviços e auditoria de saúde/segurança.

---

## 📂 Included Scripts / Scripts Inclusos

| Script | Description (EN) | Descrição (PT-BR) |
| :--- | :--- | :--- |
| [`scripts/system-health-audit.sh`](scripts/system-health-audit.sh) | Generates a complete server diagnostic report: uptime, CPU load, memory usage, filesystem utilization alerts, listening TCP/UDP ports, and recent failed SSH login attempts. | Gera um relatório completo do servidor: uptime, carga de CPU, uso de memória, alertas de partições cheias, portas TCP/UDP em escuta e tentativas falhas de login SSH. |
| [`scripts/backup-rotate.sh`](scripts/backup-rotate.sh) | Compresses target directories into timestamped `.tar.gz` archives, generates SHA-256 checksums, and prunes backups older than the retention policy (default: 7 days). | Compacta diretórios em arquivos `.tar.gz` com timestamp, gera hashes SHA-256 de integridade e remove backups antigos conforme a política de retenção. |
| [`scripts/service-watchdog.sh`](scripts/service-watchdog.sh) | Checks critical `systemd` services (e.g., `sshd`, `nginx`, `docker`, `cron`), attempts automatic restart if down, and logs recovery events. | Monitora serviços críticos do `systemd`, tenta reiniciá-los automaticamente em caso de queda e registra os eventos em log. |

---

## 🚀 Usage & Cron Scheduling / Uso e Agendamento no Cron

```bash
chmod +x scripts/*.sh

# 1. Run system health & security audit
sudo ./scripts/system-health-audit.sh

# 2. Run backup of /etc and /var/www with 14-day retention
sudo ./scripts/backup-rotate.sh /etc /var/backups/infra 14

# 3. Check critical services and auto-restart if stopped
sudo ./scripts/service-watchdog.sh ssh nginx cron
```

### Example Crontab (`crontab -e`)
```cron
# Run backup daily at 02:30 AM
30 2 * * * /opt/linux-infra-automation/scripts/backup-rotate.sh /etc /var/backups/etc 7 >> /var/log/backup-rotate.log 2>&1

# Run service watchdog every 5 minutes
*/5 * * * * /opt/linux-infra-automation/scripts/service-watchdog.sh ssh nginx docker
```
