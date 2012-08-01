data <- read.csv("result.csv", col.names=c(
    "time", "country", "product", "quality", "price", "stock"
))
data$time <- as.POSIXct(data$time, origin="1970-01-01")

layouts <- list(
    c(1),
    c(),
    c(),
    c(),
    matrix(c(1, 1, 1, 2, 2, 2,
             3, 3, 4, 4, 5, 5), 2, 6, byrow = TRUE),
    c(),
    matrix(c(1, 1, 2, 2,
             1, 1, 3, 3,
             4, 5, 6, 7), 3, 4, byrow = TRUE)
)

for (product in unique(data$product)) {
    products <- data[data$product == product, ]

    qualities <- sort(unique(products$quality))
    colors <- rainbow(length(qualities))

    layout(layouts[[length(qualities)]])

    for (quality in qualities) {
        q_products = products[products$quality == quality, ]
        plot(q_products$time, q_products$price, "l", col=colors[quality], xlab="Time", ylab="Price")

        title(paste(product, quality))
    }
}

food <- data[data$product == "Food", ]

modifiers <- c(2, 4, 6, 8, 10, 12, 20)

xrange <- range(food$time)
yrange <- c(min(food[food$quality == 1, ]$price) * 50 - 1, max(food[food$quality == 7, ]$price) * 5 + 1)
colors <- c(1:7)

layout(1)
plot(xrange, yrange, "n", xlab = "Time", ylab = "Price for 100 health")
title("Best food quality")

for (i in c(1:7)) {
    q_food <- food[food$quality == i, ]
    q_food$health <- (100 / modifiers[i] * q_food$price)
    lines(q_food$time, q_food$health, "l", col = colors[i], lwd = 3)
}

legend("topright", c("Q1", "Q2", "Q3", "Q4", "Q5", "Q6", "Q7"), col = colors, lty = 1, lwd = 10)
