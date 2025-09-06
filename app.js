const express = require("express")
const dotenv = require("dotenv")
const prisma = require('./config/dbconfig') // Импортируем Prisma клиент
dotenv.config()

const PORT = process.env.PORT
const HOST = process.env.HOST

const app = express()

// Middleware для парсинга JSON
app.use(express.json())

// Test route с проверкой подключения к БД
app.get('/', async (req, res) => {
    try {
        // Проверяем подключение к БД простым запросом
        await prisma.$queryRaw`SELECT 1`
        res.json({ 
            message: 'Server is running!', 
            database: 'Connected successfully' 
        })
    } catch (error) {
        console.error('Database connection failed:', error)
        res.status(500).json({ 
            message: 'Server is running!', 
            database: 'Connection failed',
            error: error.message 
        })
    }
})

// Graceful shutdown
process.on('SIGINT', async () => {
    console.log('Shutting down gracefully...')
    await prisma.$disconnect()
    process.exit(0)
})

process.on('SIGTERM', async () => {
    console.log('Shutting down gracefully...')
    await prisma.$disconnect()
    process.exit(0)
})

// Запускаем сервер
app.listen(PORT, HOST, () => {
    console.log(`Server started at http://${HOST}:${PORT}`)
    console.log('Prisma will connect automatically on first database request')
})