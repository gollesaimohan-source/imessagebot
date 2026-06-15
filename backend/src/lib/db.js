import mongoose from "mongoose";

export async function connectDB(){
    try{
        const mongoUri = process.env.MONGO_URI;
        if(!mongoUri){
            throw new Error("MOnGO_URI is required" )
        }
        const conn =await mongoose.connect(mongoUri)
        console.log("MongoDB connected",conn.connection.host);



    }
    catch(error){
        console.log("MongoDB connect error:",eroor.message);
        process.exit(1)
        //1 mean fail
        //0 mean succes

    }
}

 