/**
 * inventory.js: This is the main file which handles routing for viewing items,
 * adding an item, updating price for an item and deleteing an item.
 * @author: Deepthi Warrier, Sumitha Ravindran
 * @date: 22/May/2020 *
 */

var express = require('express');
var router = express.Router();
var db = require('../database');

/* GET the Index Page */
router.get('/index', function(req, res, next) {
  res.render('index');
});

/* Render the Add Items EJS Page. */
router.get('/add-item', function(req, res, next) {
  res.render('add-item', {errorMsg: ''});
});

/* Add Items to ItemDetails Table */
router.post('/add', function(req, res, next) {
      var itemname     = req.body.itemname;
      var category = req.body.category;
      var quantity         = req.body.quantity;
      var price      = req.body.price;        
   
      var sql = `INSERT INTO awsrds.itemdetails (itemName, quantity, pricePerItem, categoryName) VALUES ('${itemname}', ${quantity}, ${price}, '${category}')`;

      db.query(sql,function (err, data) {
        if (err) {
          return res.render('error', {message: 'Item already Exists in the Inventory', error: err} );
        } else{
          console.log("record inserted");   
          res.redirect('/inventory/item-list');
        }              
        });                 
});

/* Display all the items available in itemdetails table  */
router.get('/item-list', function(req, res, next) {
  var sql='SELECT * FROM awsrds.itemdetails where quantity <> 0 order by categoryName, itemName';

  db.query(sql, function (err, data, fields) {
  if (err){
    console.log(err);
    throw err;
  } 
  console.log(data);
  res.render('item-list', { title: 'Item List', itemData: data});
});
});

//The URL '/delete-item' calls the below code
router.get('/delete-item', (req, res)=>{
//Calling delete-an-item.ejs file
  res.render('delete-an-item');
    })
  
  //The below code will get the input values from the manager and perform delete operation
router.post('/delete',function(req, res) {
      console.log('Inside delete');
      console.log(req.body);
      let name = req.body.itemName;
      console.log(name);
      let sql =`DELETE FROM awsrds.itemdetails WHERE itemName= ?`;
      db.query(sql, [name], (err, results)=>{
        if(err){
          console.log("error" +err)
          return res.render('error', {message: 'Error in Deleting Item', error: err} );
        }
        //Printing the number of rows affected by delete operation
        console.log('Number of affected rows:' +results.affectedRows);
        if(results.affectedRows == 0) {
          return res.render('error', {message: 'Item doesnot Exist. Please check the Item Name', error: ""} );
        } else{
          res.redirect('/inventory/item-list'); 
        }        
      }) 
  })
  
  //The URL '/update-price' calls the below code
router.get('/update-price', (req, res)=>{
  //Calling update-item-price.ejs file
  res.render('update-item-price');
  })
  
  //The below code will get the input values from the manager and perform update operation
router.post('/update',function(req, res) {
    console.log('Inside update');
    console.log(req.body);
    let itemname = req.body.itemName;
    let price = req.body.pricePerItem;
    console.log(itemname);
    console.log(price);
  
    let sql2 =`UPDATE awsrds.itemdetails SET pricePerItem=? WHERE itemName=?`;
    db.query(sql2, [price,itemname], (err, results)=>{
  
      if(err){
        console.log("error" +err)
        return res.render('error', {message: 'Error in Deleting Item', error: err} );
      }

      //printing the number of rows updated by update operation
      console.log('Number of Updated rows:' +results.affectedRows);
        if(results.affectedRows == 0) {
          return res.render('error', {message: 'Item doesnot Exist. Please check the Item Name', error: ""} );
        } else{
          res.redirect('/inventory/item-list'); 
        }
    }) 
  })

  /*Display all the items available in priceHike view  */
  router.get('/price-hike-view', function(req, res, next) {
    var sql='SELECT * FROM awsrds.priceHike';
    db.query(sql, function (err, data, fields) {
    if (err){
      console.log(err);
      throw err;
    } 
    console.log(data);
    res.render('price-hike-view', { title: 'price-hike-view', itemsData: data});
  });
  });
  
module.exports = router;