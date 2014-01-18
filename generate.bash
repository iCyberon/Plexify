 SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

cd "${DIR}"

(openssl req -new -nodes -newkey rsa:2048 -out ./trailers.pem -keyout ./trailers.key -x509 -days 7300 -subj "/C=US/CN=trailers.apple.com") && (openssl x509 -in ./trailers.pem -outform der -out ./trailers.cer && cat ./trailers.key >> ./trailers.pem)