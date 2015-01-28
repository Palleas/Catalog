<?php
$ts = time();
$publicKey = 'ad4226afe4d476d598b8ebfb4086d5fc';
$privateKey = '35a89025a3f9182626089bcdbd51e82b4305eeac';

$params = ['apikey' => $publicKey, 'ts' => $ts, 'hash' => md5($ts.$privateKey.$publicKey)];
$url = 'http://gateway.marvel.com/v1/public/characters?'.http_build_query($params);
$content = file_get_contents($url);
$characters = array_map(function ($character) {
	$row = ['name' => $character['name'], 'uri' => $character['resourceURI']];
	if ($character['thumbnail']) {
		$row['thumbnail'] = sprintf('%s.%s', $character['thumbnail']['path'], $character['thumbnail']['extension']);
	}

	return $row;
}, json_decode($content, true)['data']['results']);

$handle = fopen(__DIR__.'/../ReactiveCSVParserTests/Fixtures/characters.csv', 'w+');

foreach ($characters as $character) {
	fputcsv($handle, $character);
}

fclose($handle);
