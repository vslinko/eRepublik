data <- read.csv("result.csv", col.names=c(
    "time", "country", "product", "quality", "price", "stock"
))
data <- data[data$product == "Food", ]
data$time <- as.POSIXct(data$time, origin="1970-01-01")

modifiers <- c(2, 4, 6, 8, 10, 12, 20)

xrange <- range(data$time)
yrange <- c(min(data[data$quality == 1, ]$price) * 50 - 1, max(data[data$quality == 7, ]$price) * 5 + 1)
colors <- c(1:7)

plot(xrange, yrange, "n", xlab = "Time", ylab = "Price for 100 health")

for (i in c(1:7)) {
    q_food <- data[data$quality == i, ]
    q_food$health <- (100 / modifiers[i] * q_food$price)
    lines(q_food$time, q_food$health, "l", col = colors[i], lwd = 3)
}

legend("topright", c("Q1", "Q2", "Q3", "Q4", "Q5", "Q6", "Q7"), col = colors, lty = 1, lwd = 10)
