
const functions = require('firebase-functions');
const admin = require('firebase-admin');
const nodemailer = require('nodemailer');



//admin.initializeApp(functions.config().functions);
admin.initializeApp();
const db = admin.firestore();


 //// FUNCTION TO SEND PUSH NOTIFICATION and MAIL WHEN INCIDENT IS BEING CREATED 

exports.createIncMessageTrigger = functions.firestore.document('incidents/{msgId}').onCreate(async (snapshot , context) => { 
  if(snapshot.empty){
    console.log('No msg to send ');
    return;
  }

 // variable from the createincmsg
  newData = snapshot.data();
  inc_created_by = newData.inc_created_by;
  link_id = newData.link_for_incident;
  incident_id = newData.incident_id;
  inc_desc = newData.inc_desc;
  inc_created_dt = newData.inc_created_dt;
  title = 'Incident has been created';

  var link_support_team;
  var link_start_point;
  var link_end_point;
  var team_manager
  tokens =[];
 /// Get device token for the user who raised incident

try{
const inccreaterdeviceTokens = await admin.firestore().collection('incrole').where('email', '==', inc_created_by).get();
  inccreaterdeviceTokens.forEach(doc => {
    console.log(doc.data().device_token);
    tokens.push(doc.data().device_token);
  });

// get token for team manager  -- first get the team name from the link id
try{
const links = await admin.firestore().collection('links').where('link_id', '==', link_id).get();  
  links.forEach(doc => {
  link_support_team = doc.data().link_support_team;
  link_start_point = doc.data().link_start_point;
  link_end_point = doc.data().link_end_point;
  console.log(doc.data().link_support_team);
});
  try{
  const teams =  await admin.firestore().collection('teams').where('team_name', '==', link_support_team).get();  
    teams.forEach(doc => {
    team_manager = doc.data().team_manager;
    console.log(doc.data().team_manager);
    });
      try{
      const mgrdeviceTokens = await admin.firestore().collection('incrole').where('email', '==', team_manager).get();
        mgrdeviceTokens.forEach(doc => {
        console.log(doc.data().device_token);
        tokens.push(doc.data().device_token);
        });             
        var payload = {
            notification : { 
              title: title + ' ' + incident_id ,
              body:  'Problem in' + link_id + '(' + link_start_point + ' From ' + link_end_point + ') \p' + inc_desc
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
          mail_to.push(inc_created_by);
          mail_to.push(team_manager);

          // create transporter object with smtp server details
          var  transporter = nodemailer.createTransport({
              host: 'smtp.office365.com',
              secureConnection: false,
              port: 587,
              requireTLS:true,
              auth: {user: '',pass: ''},
              tls: {ciphers: 'SSLv3'}
            });

          try{ 
              transporter.sendMail({
                from: '"Actoss IMT" <admin@actoss.co.in>',
                to:  mail_to ,
                subject: title + ' - ' + incident_id ,
                html: '<p> Hi All,</p> <p>An incident has beeen created </p> <p> Incident ID - ' + incident_id + '</p> <p>  Link ID'+ link_id + '</p><p> Route  - '+ link_start_point +' To ' + link_end_point + '</p><p> Issue Description ' + inc_desc +'<p> Thanks & Regards </p><p> Actoss Incident Management Team</p>'
                });
                console.log('mail sent')
                }catch(e){
                console.log(e);
                }

        }catch(e){
          console.log(e + 'error in getting team manager detail');
        }

    }catch(e){
      console.log(e + 'error in getting team detail');
    }

}catch(e){
  console.log(e + 'error in getting link detail');
}

}catch(e){
  console.log(e + 'error in getting device token detail');
}
});

//// FUNCTION TO SEND PUSH NOTIFICATION and MAIL WHEN INCIDENT IS BEING UPDATED 