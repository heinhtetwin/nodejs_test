//Load express module with `require` directive
var express = require("express")
var app = express()

//Define request response in root URL (/)
app.get('/', function (req, res) {
  res.send("Hello World! Your environment is " + process.env.NODE_ENV);
  const response = {
    status: "Ok",
    message: "Hello World!. Your environment is " + process.env.NODE_ENV
  };
  console.log(JSON.stringify(response));
})

app.get('/admin', function (req, res) {
  res.send("This is Admin console, only specific IP should be access! Your environment is " + process.env.NODE_ENV);
  const response = {
    status: "Ok",
    message: "This is Admin console, only specific IP should be access. Your environment is " + process.env.NODE_ENV
  };
  console.log(JSON.stringify(response));
})

//Launch listening server on port 2019
app.listen(2019, function () {
  const response = {
    status: "Ok",
    message: "app listening on port 2019. Your environment is " + process.env.NODE_ENV
  };
  console.log(JSON.stringify(response));
})