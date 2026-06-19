import ImageKit, {toFile} from "@imagekit/nodejs";

const imagekit = new Imagekit({privateKey: Process.env.IMAGEKIT_PRIVATE_KEY });

function hasImagekitConfig(){
    return Boolean(process.env.IMAGEKIT_PRIVATE_KEY);


} 

//image.png image.png
function createFileName(originalName = "upload") {
  const safeName = originalName.replace(/[^a-zA-Z0-9._-]/g, "_");
  return `chat-${Date.now()}-${safeName}`;
}

async function uploadChatMedia(file){
  const fileName = createFileName(file.originalname);

    const result = await imagekit.files.upload({
    file: await toFile(file.buffer, fileName, { type: file.mimetype }),
    fileName,
    folder: "/chat",
  });
  return result.url;
    
}

export { uploadChatMedia, hasImagekitConfig };
