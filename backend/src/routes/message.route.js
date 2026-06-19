import express from "express";
import { getUsersForSidebar,
    getconversationsForSidebar,
    getMessages,sendMessage
} from "../controllers/message.controller.js";
import { protectRoute } from "../middleware/auth.middleware.js";
import { upload } from "../middleware/upload.middleware.js";




const router = express.Router();
router.use(protectRoute);


router.get("/users", getUsersForSidebar);
router.get("/conversations",getconversationsForSidebar);
router.get("/:id", getMessages);
router.post("/send/:id",upload.single("media"), sendMessage);
//todo: show in the forntend part
export default router;
