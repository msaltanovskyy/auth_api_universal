const express = require("express")
const dotenv = require("dotenv")
const db = require('./config/dbconfig')
dotenv.config()

const PORT = process.env.PORT
const HOST = process.env.HOST

const app = express()

db.connect((err) => {
    if (err) {
        console.error('Database connection failed:', err)
        process.exit(1) // Exit process if database connection fails
    } else {
        console.log('Connected to database successfully')
        
        // Start server only after database connection is established
        app.listen(PORT, HOST, () => {
            console.log(`Server started at http://${HOST}:${PORT}`)
        })
    }
})

//test route
app.get('/', (req, res) => {
    res.json({ message: 'Server is running!', database: 'Connected' })
})
