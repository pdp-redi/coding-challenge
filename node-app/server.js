var express  = require('express');
var app      = express();
var mongoose = require('mongoose');
var port     = process.env.PORT || 8080;
var database = require('./config/database');
var bodyParser = require('body-parser');
var methodOverride = require('method-override');

mongoose.connect(database.remoteUrl, database.options)
    .then(() => console.log('MongoDB Atlas connected successfully'))
    .catch(err => console.error('MongoDB Atlas connection error:', err));

mongoose.connection.on('error', (err) => {
    console.error('MongoDB connection error:', err);
});

mongoose.connection.on('disconnected', () => {
    console.log('MongoDB disconnected');
});

process.on('SIGINT', () => {
    mongoose.connection.close(() => {
        console.log('MongoDB connection closed due to app termination');
        process.exit(0);
    });
});

app.use(express.static('./public'));
app.use(bodyParser.urlencoded({'extended':'true'}));
app.use(bodyParser.json());
app.use(bodyParser.json({ type: 'application/vnd.api+json' }));
app.use(methodOverride('X-HTTP-Method-Override'));

require('./app/routes')(app);

app.listen(port);
console.log("App listening on port " + port);