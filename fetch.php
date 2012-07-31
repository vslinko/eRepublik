<?php

if (!is_readable(__DIR__ . '/config.php') || !is_array($config = include __DIR__ . '/config.php')) {
    exit("Configuration file invalid");
}

require_once __DIR__ . '/vendor/autoload.php';

$defaultConfig = array(
    'client_path' => __DIR__ . '/client.txt',
    'result_path' => __DIR__ . '/result.csv',
    'countries' => array(
        array('name' => 'Russia', 'id' => 41),
    ),
    'products' => array(
        array('name' => 'Food', 'id' => 1, 'max_quality' => 7),
        array('name' => 'Weapons', 'id' => 2, 'max_quality' => 7),
        array('name' => 'Moving Tickets', 'id' => 3, 'max_quality' => 5),
        array('name' => 'Food Raw Materials', 'id' => 7, 'max_quality' => 1),
        array('name' => 'Weapon Raw Materials', 'id' => 12, 'max_quality' => 1),
        array('name' => 'Hospital', 'id' => 5, 'max_quality' => 5),
        array('name' => 'Defence System', 'id' => 6, 'max_quality' => 5),
    ),
);
$config = array_merge($defaultConfig, $config);

if (!isset($config['email']) || !isset($config['password'])) {
    exit("You must configure you email and password");
}


if (is_readable($config['client_path'])) {
    list($history, $cookieJar) = unserialize(file_get_contents($config['client_path']));
    $client = new Goutte\Client(array(), $history, $cookieJar);
    unset($history, $cookieJar);

} else {
    AUTH:
    $client = new Goutte\Client();

    $form = $client->request('GET', 'http://www.erepublik.com/en')->selectButton('Sign In')->form();
    $client->submit($form, array(
        'citizen_email' => $config['email'],
        'citizen_password' => $config['password'],
    ));

    file_put_contents($config['client_path'], serialize(array(
        $client->getHistory(),
        $client->getCookieJar(),
    )));
}


$fp = fopen($config['result_path'], 'a');
$time = time();

foreach ($config['countries'] as $country) {
    foreach ($config['products'] as $product) {
        for ($quality = 1; $quality <= $product['max_quality']; $quality++) {
            $url = "http://economy.erepublik.com/en/market/{$country['id']}/{$product['id']}/$quality/citizen/0/price_asc/1";
            $crawler = $client->request('GET', $url);

            if (count($crawler->selectButton('Login')) > 0) {
                fclose($fp);
                goto AUTH;
            }

            $nodes = $crawler->filter('.price_sorted tr');

            if (count($nodes) > 0) {
                $node = $nodes->first();

                $price = (float)$node->filter('.m_price')->text();
                $stock = 0;

                $i = 0;
                do {
                    $stock += (int)$node->filter('.m_stock')->text();
                    $node = $nodes->eq(++$i);
                } while (count($node) > 0 && $price == (float)$node->filter('.m_price')->text());

                echo "{$product['name']} Q{$quality} in {$country['name']}: {$price} x {$stock}\n";

                fputcsv($fp, array(
                    $time,
                    $country['name'],
                    $product['name'],
                    $quality,
                    $price,
                    $stock,
                ));
            } else {
                echo "{$product['name']} Q{$quality} in {$country['name']}: FAIL\n";
            }
        }
    }
}

fclose($fp);
