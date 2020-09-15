/**
 * users.js: This is the main registeration file in the project.
 * Users have many routes for authentication task. A user is able to register and validate his information.
 * Once a user gets registered, we add him to the database manaers table
 * @author: Adam Shandi, Deepthi Warrier
 * @date: 22/May/2020 *
 */

const express = require("express");
const router = express.Router();

// AWS Database
let db = require("../database");

// Render The login Page
router.get('/', (req, res) => {
    res.render('login', {errorMsg: ''});
});

// Code for Login - Crosscheck if the username password entered matches with the data present in the database. If it doesn't match, redirect to login page by also sending an error Msg
router.post('/log', (req, res) => {
    var username     = req.body.username;
    var password = req.body.password;    

    var sql='SELECT * FROM awsrds.users where username = \'' + username + '\' and password = \'' + password + '\'';

    console.log(sql);

    db.query(sql, function (err, data, fields) {
        if (err){
            console.log(err);
            throw err;
        } 

        console.log(data);
        console.log(data[0]);
        if (data[0] === undefined || data === undefined) { 
            res.render('login', {errorMsg: 'Invalid username/password. Please enter the right credentials / register if you are a new user.'}) ;
        } else {
            res.render('index');
        }   
    });
});

// Render the registration page
router.get("/register", (req, res) => res.render("register", {errorMsg: ''}));

//When the register button is clicked on registration page
router.post("/register", (req, res) => {

    let {first, last, username, email, phone, gender, password, password2} = req.body

    if(password != password2) {
       return res.render("register", {errorMsg: 'The password and the confirm password do not match'});
    }
    
    // Check if user is registered already
    let checkRegistered = `SELECT * FROM awsrds.managers WHERE email=?`;

    db.query(checkRegistered, email, (err, data, fields) => {
        if (err) {
            console.log('error occured at the first query')
            throw err
        }

        if (data[0] === undefined) {
            console.log(data)
            console.log("user is not exist");
            //  console.log(fields)

            let theQuery = `INSERT INTO awsrds.managers (firstname,lastname, phone, email, gender) VALUES(?, ?, ?, ?, ?)`;
            let values = [first, last, phone, email, gender];

            db.query(theQuery, values, (err, data) => {
                if (err) {
                    console.log("Error occured at the second qury" + err)
                    throw err                   
                } else {
                    console.log("Query has been inserted for managers");
                    console.log('Now adding to users table')
                    let theUserQuery = `INSERT INTO awsrds.users (username, password) VALUES(?, ?)`
                    let tempvals = [username, password]

                    db.query(theUserQuery, tempvals, (err, result) => {
                        console.log('Users is being added')
                        if (err) {
                            console.log('Error in DB before add the user')
                            throw err
                        } else {
                            console.log('Success on adding user ')
                        }
                    })
                    res.render("login", {errorMsg: 'Manager added successfully. Please login now.'});
                }
            });
        } else {
            console.log('user exist in DB')
            console.log('Render user to log in instead')
            console.log(data)
            res.render('login', {errorMsg: 'Manager already exists in DB!'});
        }
    });
});

module.exports = router;
