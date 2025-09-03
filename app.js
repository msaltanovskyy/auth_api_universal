const express = require("express")
const dotenv = require("dotenv")

dotenv.config()

const PORT = process.env.PORT
const HOST = process.env.HOST

const app = express()

app.listen(PORT,HOST, () => {
    console.log(`Server start http://${HOST}:${PORT}`)
})