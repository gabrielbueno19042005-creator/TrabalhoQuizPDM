import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class QuizService {
  // --- URL da Groq ---
  final String _url = 'https://api.groq.com/openai/v1/chat/completions';

  // --- PLANO B: Perguntas locais de emergência ---
  final Map<String, List<Map<String, dynamic>>> _questoesLocais = {
    "Jogos": [
      {
        "pergunta": "Qual o jogo mais vendido do mundo?",
        "opcoes": ["Minecraft", "GTA V", "Tetris", "Pong"],
        "correta": 0
      },
      {
        "pergunta": "Quem é o protagonista de 'The Legend of Zelda'?",
        "opcoes": ["Zelda", "Link", "Ganon", "Mario"],
        "correta": 1
      },
      {
        "pergunta": "Qual empresa criou o console PlayStation?",
        "opcoes": ["Microsoft", "Nintendo", "Sony", "Sega"],
        "correta": 2
      },
      {
        "pergunta": "De qual jogo é o personagem Master Chief?",
        "opcoes": ["Doom", "Halo", "Gears of War", "Destiny"],
        "correta": 1
      },
      {
        "pergunta": "Em que ano foi lançado o primeiro Super Mario Bros?",
        "opcoes": ["1981", "1983", "1985", "1989"],
        "correta": 2
      },
    ],
    "Filmes": [
      {
        "pergunta": "Qual filme ganhou o primeiro Oscar de Melhor Animação?",
        "opcoes": ["Shrek", "Toy Story", "Rei Leão", "Aladdin"],
        "correta": 0
      },
      {
        "pergunta": "Quem dirigiu o filme 'Pulp Fiction'?",
        "opcoes": [
          "Steven Spielberg",
          "Quentin Tarantino",
          "Martin Scorsese",
          "Christopher Nolan"
        ],
        "correta": 1
      },
      {
        "pergunta": "Qual é a maior bilheteria da história do cinema?",
        "opcoes": ["Avatar", "Vingadores: Ultimato", "Titanic", "Star Wars"],
        "correta": 0
      },
      {
        "pergunta": "Qual ator interpreta o Homem de Ferro?",
        "opcoes": [
          "Chris Evans",
          "Chris Hemsworth",
          "Robert Downey Jr.",
          "Mark Ruffalo"
        ],
        "correta": 2
      },
      {
        "pergunta":
            "Em qual filme os personagens entram nos sonhos das pessoas?",
        "opcoes": [
          "Matrix",
          "Interestelar",
          "A Origem (Inception)",
          "O Show de Truman"
        ],
        "correta": 2
      },
    ],
    "Esportes": [
      {
        "pergunta": "De quanto em quantos anos ocorre a Copa do Mundo?",
        "opcoes": ["2 anos", "4 anos", "6 anos", "Anual"],
        "correta": 1
      },
      {
        "pergunta": "Qual país tem mais títulos de Copa do Mundo de Futebol?",
        "opcoes": ["Alemanha", "Itália", "Argentina", "Brasil"],
        "correta": 3
      },
      {
        "pergunta": "Quantos jogadores formam um time de basquete em quadra?",
        "opcoes": ["5", "6", "7", "11"],
        "correta": 0
      },
      {
        "pergunta": "Qual esporte o Michael Phelps pratica?",
        "opcoes": ["Atletismo", "Ginástica", "Natação", "Ciclismo"],
        "correta": 2
      },
      {
        "pergunta":
            "Qual arte marcial é conhecida como 'a arte das oito armas'?",
        "opcoes": ["Karatê", "Judô", "Muay Thai", "Taekwondo"],
        "correta": 2
      },
    ],
    "Música": [
      {
        "pergunta": "Quem é conhecido como o Rei do Pop?",
        "opcoes": ["Elvis Presley", "Michael Jackson", "Madonna", "Prince"],
        "correta": 1
      },
      {
        "pergunta": "Qual banda gravou o álbum 'Abbey Road'?",
        "opcoes": [
          "The Rolling Stones",
          "The Who",
          "Pink Floyd",
          "The Beatles"
        ],
        "correta": 3
      },
      {
        "pergunta": "Quantas cordas tem um violão tradicional?",
        "opcoes": ["4", "5", "6", "7"],
        "correta": 2
      },
      {
        "pergunta": "Qual cantor é famoso pelo estilo 'Reggae'?",
        "opcoes": ["Bob Dylan", "Bob Marley", "Jimi Hendrix", "Eric Clapton"],
        "correta": 1
      },
      {
        "pergunta": "De qual país é originário o K-Pop?",
        "opcoes": ["Japão", "China", "Coreia do Sul", "Tailândia"],
        "correta": 2
      },
    ],
    "Geografia": [
      {
        "pergunta": "Qual a capital do Brasil?",
        "opcoes": ["São Paulo", "Rio de Janeiro", "Brasília", "Salvador"],
        "correta": 2
      },
      {
        "pergunta": "Qual é o maior continente do mundo?",
        "opcoes": ["África", "América", "Ásia", "Europa"],
        "correta": 2
      },
      {
        "pergunta": "Qual rio corta a cidade do Cairo?",
        "opcoes": ["Rio Amazonas", "Rio Nilo", "Rio Tigre", "Rio Tâmisa"],
        "correta": 1
      },
      {
        "pergunta": "Qual o menor país do mundo?",
        "opcoes": ["Mônaco", "Malta", "Vaticano", "San Marino"],
        "correta": 2
      },
      {
        "pergunta": "Em qual país fica o deserto do Atacama?",
        "opcoes": ["Peru", "Chile", "Bolívia", "Argentina"],
        "correta": 1
      },
    ],
  };

  Future<List<Map<String, dynamic>>> gerarQuestoes(
      String tema, int quantidade) async {
    try {
      // 1. Lê a chave do .env (Coloque sua chave da Groq lá)
      // Tenta pegar a chave real injetada pelo Codemagic. 
// Se não existir (rodando local na sua máquina), ele usa o arquivo chave.env normal.
            final String apiKey = String.fromEnvironment(
              'GROQ_KEY', 
              defaultValue: dotenv.env['_apiKey'] ?? '',
            );
      if (apiKey.isEmpty) throw Exception('Chave API vazia');

      final uri = Uri.parse(_url);

      // 2. Faz a requisição no formato padrão OpenAI/Groq
      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $apiKey', // A chave agora vai no Header!
            },
            body: jsonEncode({
              "model": "llama3-8b-8192", // Modelo ultra rápido da Meta via Groq
              "messages": [
                {
                  "role": "system",
                  "content":
                      "Você é um gerador de quiz estrito. Responda APENAS com um array JSON puro, sem textos adicionais, sem saudações e sem formatação markdown (sem ```json). "
                          "Formato OBRIGATÓRIO exato:\n"
                          "[{\"pergunta\": \"texto da pergunta 1\", \"opcoes\": [\"a\", \"b\", \"c\", \"d\"], \"correta\": 0}]"
                },
                {
                  "role": "user",
                  "content":
                      "Tema: $tema. Gere $quantidade perguntas diferentes, cada uma com 4 opções e indique o índice da resposta correta (0 a 3)."
                }
              ],
              "temperature":
                  0.5 // 0.5 equilibra criatividade com consistência estrutural
            }),
          )
          .timeout(const Duration(
              seconds:
                  10)); // Se demorar mais de 10s, força o erro para usar o plano local

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // O caminho para encontrar o texto na Groq é diferente do Gemini
        String content = data['choices'][0]['message']['content'];

        // Limpa formatação markdown caso a IA coloque
        content =
            content.replaceAll('```json', '').replaceAll('```', '').trim();

        // Garante que estamos pegando apenas o Array JSON
        int start = content.indexOf('[');
        int end = content.lastIndexOf(']');
        if (start != -1 && end != -1) {
          content = content.substring(start, end + 1);
        }

        List<dynamic> jsonList = jsonDecode(content);

        // Retorna a lista vinda da IA
        return List<Map<String, dynamic>>.from(jsonList);
      } else {
        print("Erro detalhado da Groq: ${response.body}");
        throw Exception('Status: ${response.statusCode}');
      }
    } catch (e) {
      print(
          "API Falhou ou demorou. Ativando perguntas locais para: $tema. Motivo: $e");

      // Se der qualquer erro de chave, timeout ou limite, puxa o banco local salvando o app!
      return _questoesLocais[tema] ??
          [
            {
              "pergunta": "Ops, tema não encontrado. Qual a cor do céu?",
              "opcoes": ["Azul", "Verde", "Roxo", "Amarelo"],
              "correta": 0
            }
          ];
    }
  }
}
