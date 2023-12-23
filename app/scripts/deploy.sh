# PI.ps1

$PULPO_DIR = '\\rafiki.cavabianca.org\datos\usuarios\abs\docs\GitHub\rpulpo'
$PORT = '2948'
cd "$PULPO_DIR"
bundle exec app/main.rb -o 0.0.0.0 -e production -p $PORT