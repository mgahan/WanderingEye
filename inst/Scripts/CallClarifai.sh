curl -X POST \
  -H "Authorization: Key $1" \
  -H "Content-Type: application/json" \
  -d '
  {
    "inputs": [
{
  "data": {
    "image": {
    "'$3'": "'$2'"
    }
  }
}
    ]
  }' https://api.clarifai.com/v2/models/aaa03c23b3724a16a56b629203edc62c/outputs