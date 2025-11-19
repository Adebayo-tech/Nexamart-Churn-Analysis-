-- BASIC WORD FREQUENCY ANALYSIS

with recursive numbers as (
  select 
    1 as n 
  union all 
  select 
    n + 1 
  from 
    numbers 
  where 
    n < 100
), 
words as (
  select 
    lower(
      trim(
        replace(
          replace(
            substring_index(
              substring_index(complaint_text, ' ', n.n), 
              ' ', 
              -1
            ), 
            ',', 
            ''
          ), 
          '.', 
          ''
        )
      )
    ) words, 
    complaint_type, 
    product_category 
  from 
    complaints c 
    join numbers n on n.n <= length(complaint_text) - length(
      replace(Complaint_Text, ' ', '')+ 1
    )
) 
select 
  words, 
  count(*) frequency, 
  count(distinct product_category) product_category_covered, 
  count(distinct complaint_type) complaint_type_covered 
from 
  words 
where 
  length(words) > 2 
  and words not in (
    'the', 'and', 'has', 'are', 'was', 'for'
  ) 
group by 
  words 
order by 
  frequency desc;
  
  
  
-- PRODUCT SPECIFIC COMPLAINTS WORDS

with recursive numbers as (
  select 
    1 as n 
  union all 
  select 
    n + 1 
  from 
    numbers 
  where 
    n < 100
), 
split_text as (
  select 
    Product_Category, 
    Complaint_Type, 
    lower(
      trim(
        replace(
          replace(
            substring_index(
              substring_index(c.complaint_text, ' ', n.n), 
              ' ', 
              -1
            ), 
            ',', 
            ''
          ), 
          '.', 
          ''
        )
      )
    ) words 
  from 
    complaints c 
    join numbers n on n.n <= length(complaint_text) - length(
      replace(complaint_text, ' ', '')+ 1
    )
), 
filtered_words as (
  select 
    Product_Category, 
    Complaint_Type, 
    words, 
    count(*) frequency 
  from 
    split_text 
  where 
    length(words) > 2 
    and words not in (
      'the', 'and', 'has', 'was', 'two', 'for', 
      'one', 'are'
    ) 
  group by 
    Product_Category, 
    Complaint_Type, 
    words
) 
select 
  Product_Category, 
  Complaint_Type, 
  words, 
  frequency, 
  sum(frequency) over (
    partition by product_category, complaint_type
  ) total_words_prodcat_comtyp, 
  round(
    frequency * 100 / sum(frequency) over (
      partition by product_category, complaint_type
    ), 
    2
  ) percentage_ocurence_category 
from 
  filtered_words 
where 
  frequency > 2 
order by 
  percentage_ocurence_category desc;
  
  
  
-- COMPLAINTS BIGRAM ANALYSIS

with recursive numbers as (
  select 
    1 as n 
  union all 
  select 
    n + 1 
  from 
    numbers 
  where 
    n < 100
), 
words as (
  select 
    complaint_id, 
    complaint_type, 
    product_category, 
    n.n position, 
    lower(
      trim(
        replace(
          replace(
            substring_index(
              substring_index(complaint_text, ' ', n.n), 
              ' ', 
              -1
            ), 
            ',', 
            ''
          ), 
          '.', 
          ''
        )
      )
    ) words 
  from 
    complaints c 
    join numbers n on n.n <= length(complaint_text) - length(
      replace(complaint_text, ' ', '')+ 1
    )
), 
bigram as (
  select 
    w1.complaint_id, 
    w1.complaint_type, 
    w1.product_category, 
    concat(w1.words, ' ', w2.words) paired_words 
  from 
    words w1 
    join words w2 on w1.complaint_id = w2.complaint_id 
    and w1.position = w2.position - 1 
    and w1.words <> w2.words 
  where 
    length(w1.words) > 2 
    and length(w2.words) > 2 
    and w1.words not in (
      'the', 'and', 'has', 'was', 'two', 'for', 
      'one', 'are'
    ) 
    and w2.words not in (
      'the', 'and', 'has', 'was', 'two', 'for', 
      'one', 'are'
    )
), 
paired as (
  select 
    paired_words, 
    count(*) frequency, 
    complaint_type, 
    product_category 
  from 
    bigram 
  group by 
    paired_words, 
    complaint_type, 
    product_category 
  order by 
    frequency desc
) 
select 
  * 
from 
  (
    select 
      *, 
      dense_rank() over (
        partition by complaint_type, 
        product_category 
        order by 
          frequency desc
      ) ranks 
    from 
      paired
  ) t 
where 
  ranks <= 3;
-- -- =====================================================================================
-- -- =====================================================================================
--                 CANCELLATION REASON ANALYSIS
-- -- =====================================================================================
-- -- =====================================================================================


-- BASIC WORD FREQUENCY ANALYSIS

with recursive numbers as (
  select 
    1 as n 
  union all 
  select 
    n + 1 
  from 
    numbers 
  where 
    n < 100
), 
words as (
  select 
    Product_Category, 
    Payment_Method, 
    lower(
      trim(
        replace(
          replace(
            substring_index(
              substring_index(cancellation_reason, ' ', n.n), 
              ' ', 
              -1
            ), 
            ',', 
            ''
          ), 
          '.', 
          ''
        )
      )
    ) words 
  from 
    order_cancellations o 
    join numbers n on n.n <= length(Cancellation_Reason) - length(
      replace(Cancellation_Reason, ' ', '')+ 1
    )
) 
select 
  words, 
  count(*) frequency, 
  count(distinct product_category) product_category_covered, 
  count(distinct payment_method) payment_method_covered 
from 
  words 
where 
  length(words) > 2 
  and words not in (
    'the', 'one', 'for', 'has', 'and', 'too', 
    'are', 'was', 'had', 'its'
  ) 
group by 
  words 
order by 
  frequency desc;
  
  
  
-- PRODUCT SPECIFIC CANCELLATION REASONS WORDS

with recursive numbers as (
  select 
    1 as n 
  union all 
  select 
    n + 1 
  from 
    numbers 
  where 
    n < 100
), 
words as (
  select 
    Product_Category, 
    Payment_Method, 
    lower(
      trim(
        replace(
          replace(
            substring_index(
              substring_index(cancellation_reason, ' ', n.n), 
              ' ', 
              -1
            ), 
            ',', 
            ''
          ), 
          '.', 
          ''
        )
      )
    ) words 
  from 
    order_cancellations o 
    join numbers n on n.n <= length(Cancellation_Reason) - length(
      replace(Cancellation_Reason, ' ', '')+ 1
    )
), 
filtered_words as (
  select 
    words, 
    count(*) frequency, 
    product_category, 
    payment_method 
  from 
    words 
  where 
    length(words) > 2 
    and words not in (
      'the', 'one', 'for', 'has', 'and', 'too', 
      'are', 'was', 'had', 'its'
    ) 
  group by 
    product_category, 
    payment_method, 
    words
) 
select 
  words, 
  product_category, 
  payment_method, 
  frequency, 
  sum(frequency) over (
    partition by product_category, payment_method
  ) freq_cat_meth, 
  concat(
    round(
      frequency * 100 / sum(frequency) over (
        partition by product_category, payment_method
      ), 
      2
    ), 
    '%'
  ) percentage_frequency 
from 
  filtered_words 
order by 
  percentage_frequency desc;
  
  
  
-- CANCELLATION REASONS BIGRAM ANALYSIS

with recursive numbers as (
  select 
    1 as n 
  union all 
  select 
    n + 1 
  from 
    numbers 
  where 
    n < 100
), 
words as (
  select 
    Order_ID, 
    Product_Category, 
    Payment_Method, 
    n.n position, 
    lower(
      trim(
        replace(
          replace(
            substring_index(
              substring_index(cancellation_reason, ' ', n.n), 
              ' ', 
              -1
            ), 
            ',', 
            ''
          ), 
          '.', 
          ''
        )
      )
    ) words 
  from 
    order_cancellations o 
    join numbers n on n.n <= length(Cancellation_Reason) - length(
      replace(Cancellation_Reason, ' ', '')+ 1
    )
), 
bigram as (
  select 
    w1.order_id, 
    w1.Product_Category, 
    w1.Payment_Method, 
    concat(w1.words, ' ', w2.words) paired_words 
  from 
    words w1 
    join words w2 on w1.order_id = w2.order_id 
    and w1.position = w2.position - 1 
    and w1.words <> w2.words 
  where 
    length(w1.words) > 2 
    and length(w2.words) > 2 
    and w1.words not in (
      'the', 'and', 'has', 'was', 'two', 'for', 
      'one', 'are'
    ) 
    and w2.words not in (
      'the', 'and', 'has', 'was', 'two', 'for', 
      'one', 'are'
    )
), 
paired as (
  select 
    paired_words, 
    product_category, 
    payment_method, 
    count(*) frequency 
  from 
    bigram 
  group by 
    paired_words, 
    product_category, 
    payment_method 
  order by 
    frequency desc
) 
select 
  * 
from 
  (
    select 
      *, 
      dense_rank() over (
        partition by product_category, 
        payment_method 
        order by 
          frequency desc
      ) ran_k 
    from 
      paired
  ) a 
where 
  ran_k <= 3
