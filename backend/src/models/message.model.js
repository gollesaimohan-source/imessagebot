import mongoose from "mongoose";

const messageSchema= new mongoose.Schema({
    senderId:{
        type:mongoose.Schema.Types.ObjectId,
        ref:"User",
        required:true,
    },
    reciverId:{
        type: mongoose.Schema.Types.ObjectId,
        ref:"User",
        required:true,
    },
    text:{
        type:String,
    },
    video:{
        type:String,
    },
    image:{
        type:String,
    }
    


},{timeStamp:true},);


const Message= mongoose.model("Message",messageSchema);
export default Message;

