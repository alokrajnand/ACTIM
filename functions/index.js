const functions = require('firebase-functions');
const admin = require('firebase-admin');
const nodemailer = require('nodemailer');

/// Initialize the application

//admin.initializeApp(functions.config().functions);
admin.initializeApp();
const db = admin.firestore();


 //// FUNCTION TO SEND PUSH NOTIFICATION WHEN INCIDENT IS BEING CREATED 

exports.createIncMessageTrigger = functions.firestore.document('createincmsg/{msgId}').onCreate(async (snapshot , context) => { 
  if(snapshot.empty){
    console.log('No msg to send ');
    return;
  }

 // variable from the createincmsg

  newData = snapshot.data();
  inc_raised_by = newData.inc_raised_by;
  link_id = newData.link_id;
  incident_id = newData.incident_id;
  msg = newData.msg;
  title = newData.title;
  var link_support_team;
  var link_start_point;
  var link_end_point;
  var team_manager

  tokens =[];
 /// Get device token for the user who raised incident

  const inccreaterdeviceTokens = await admin.firestore().collection('incrole').where('email', '==', inc_raised_by).get();

  inccreaterdeviceTokens.forEach(doc => {
    console.log(doc.data().device_token);
    tokens.push(doc.data().device_token);
  });

// get token for team manager  -- first get the team name from the link id

const links = await admin.firestore().collection('links').where('link_id', '==', link_id).get();  
  links.forEach(doc => {
  link_support_team = doc.data().link_support_team;
  link_start_point = doc.data().link_start_point;
  link_end_point = doc.data().link_end_point;
  console.log(doc.data().link_support_team);
});

// get the  email id for the team manager

const teams =  admin.firestore().collection('teams').where('team_name', '==', link_support_team).get();  
  teams.forEach(doc => {
  team_manager = doc.data().team_manager;
  console.log(doc.data().team_manager);
});

  const mgrdeviceTokens = admin.firestore().collection('incrole').where('email', '==', team_manager).get();

  mgrdeviceTokens.forEach(doc => {
    console.log(doc.data().device_token);
    tokens.push(doc.data().device_token);
  });


//// send push notification --

  var payload = {
      notification : { 
            title: incident_id + ' ' + title,
            body:  'Problem in' + link_id + '(' + link_start_point + ' From ' + link_end_point + ') \p' + msg
            },
            data: { click_action: 'FLUTTER_NOTIFICATION_CLICK',message: 'message'}
          }

/// Send notifcation
      
      try{
        const response = await admin.messaging().sendToDevice(tokens, payload);
        console.log('notification sent');
      }catch(e){
        console.log('error');
      }
  

/// Send mail 

var mail_to = []
mail_to.push(inc_raised_by);
mail_to.push(team_manager);

// create transporter object with smtp server details
var  transporter = nodemailer.createTransport({
    host: 'smtp.office365.com',
    secureConnection: false,
    port: 587,
    requireTLS:true,
    auth: {
        user: 'admin@actoss.co.in',
        pass: 'Act!1234'
    },
    tls: {
        ciphers: 'SSLv3'
        }
});


try{ 
    transporter.sendMail({
        from: '"Actoss IMT" <admin@actoss.co.in>',
        to:  mail_to ,
        subject: incident_id + ' - ' + title ,
        html: '<p>Hi All,</p> <p>An incident has beeen created </p> <p> Incident ID - ' + incident_id + '</p> <p>  Link ID'+ link_id + '</p><p> Route  - '+ link_start_point +' To ' + link_end_point + '</p><p> Issue Description ' + msg +'<p> Thanks - Actoss Incident Management Team</p>'
    });
    console.log('mail sent')
  }catch(e){
    console.log(e);
  }
});


/// Send push notification and mail to all the concern person 

exports.notificationTrigger = functions.firestore.document('notificationmsg/{msgId}').onCreate(async (snapshot , context) => { 
  if(snapshot.empty){
    console.log('No msg to send ');
    return;
  }

 // variable from the createincmsg

  newData = snapshot.data();
  inc_raised_by = newData.inc_raised_by;
  link_id = newData.link_id;
  incident_id = newData.incident_id;
  msg = newData.msg;
  title = newData.title;
  var link_support_team;
  var link_start_point;
  var link_end_point;
  var team_manager

  tokens =[];
 /// Get device token for the user who raised incident

  const inccreaterdeviceTokens = await admin.firestore().collection('incrole').where('email', '==', inc_raised_by).get();

  inccreaterdeviceTokens.forEach(doc => {
    console.log(doc.data().device_token);
    tokens.push(doc.data().device_token);
  });

// get token for team manager  -- first get the team name from the link id

const links = await admin.firestore().collection('links').where('link_id', '==', link_id).get();  
  links.forEach(doc => {
  link_support_team = doc.data().link_support_team;
  link_start_point = doc.data().link_start_point;
  link_end_point = doc.data().link_end_point;
  console.log(doc.data().link_support_team);
});


  const teamdeviceTokens = await admin.firestore().collection('incrole').where('team', '==', link_support_team).get();

  teamdeviceTokens.forEach(doc => {
    console.log(doc.data().device_token);
    tokens.push(doc.data().device_token);
  });


//// send push notification --

  var payload = {
      notification : { 
            title: incident_id + ' ' + title,
            body:  'Problem in' + link_id + '(' + link_start_point + ' From ' + link_end_point + ') \p' + msg
            },
            data: { click_action: 'FLUTTER_NOTIFICATION_CLICK',message: 'message'}
          }

/// Send notifcation
      
      try{
        const response = await admin.messaging().sendToDevice(tokens, payload);
        console.log('notification sent');
      }catch(e){
        console.log('error');
      }
  

/// Send mail 


var mail_to = []
mail_to.push(inc_raised_by);


// get mail id for all the team member
const teamemails = await admin.firestore().collection('incrole').where('team', '==', link_support_team).get();
  teamemails.forEach(doc => {
    console.log(doc.data().email);
    mail_to.push(doc.data().email);
  });

// create transporter object with smtp server details
var  transporter = nodemailer.createTransport({
    host: 'smtp.office365.com',
    secureConnection: false,
    port: 587,
    requireTLS:true,
    auth: {
        user: 'admin@actoss.co.in',
        pass: 'Act!1234'
    },
    tls: {
        ciphers: 'SSLv3'
        }
});


try{ 
    transporter.sendMail({
        from: 'admin@actoss.co.in',
        to:  mail_to ,
        subject: incident_id + '' + title,
        text: 'Hi All An incident has beeen created with'+ incident_id + '. Link with'+ link_id + ' - From '+ link_start_point +' To ' + link_end_point + 'is broken . Issue Description ' + msg 
    });
    console.log('mail sent')
  }catch(e){
    console.log(e);
  }
});