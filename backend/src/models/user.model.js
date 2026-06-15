import mongoose from "mongoose"

const userSchema= new mongoose.Schema({

    clerkId:{
        type:String,
        required:true,
        unique:true,
    },
    emali:{
        type:String,
        required:true,
        unique:true,
    },
    fullName:{
        type:String,
        required:true,
        unique:true,
    },
    profilePiC:{
        type:String,
        default:"",
    },

},{timeStamps:true},); //craetedat or updatedat


const User = mongoose.model("User",userSchema)
export default User;

