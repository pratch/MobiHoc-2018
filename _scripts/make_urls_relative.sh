sed -i .bak 's|"/siceac/sice2020/|"|g' ../_site/*.html && rm ../_site/*.bak
sed -i .bak "s|'/siceac/sice2020/'|'https://sice.jp/siceac/sice2020/'|g" ../_site/*.html && rm ../_site/*.bak
sed -i .bak "s|'/siceac/sice2020/|'|g" ../_site/*.html && rm ../_site/*.bak
sed -i .bak "s|url(/siceac/sice2020/assets/|url(|g" ../_site/assets/main.css && rm ../_site/assets/*.bak
