<?php

$list_of_students = array(
    "steve",
    "samantha",
    "noodle",
    "ham_sandwich",
    "cheese_burger"
);

print_r($list_of_students);
array_pop($list_of_students);
print_r($list_of_students);
array_push($list_of_students, "lilly");
print_r($list_of_students);
